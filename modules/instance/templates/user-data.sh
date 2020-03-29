#!/usr/bin/env bash

set -ex


# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1


# Grab from here https://github.com/leboncoin/terraform-aws-nvme-example/tree/master/scripts
function nvme_alias {
  local -r volumes_name=$(find /dev | grep -i 'nvme[0-21]n1$')

  echo "install nvme-cli"
  apt update
  apt install -y nvme-cli

  echo "---> volumes list:"
  echo $${volumes_name[@]} | tr " " "\n"

  for volume in $${volumes_name}
  do
    alias=$(nvme id-ctrl -v "$${volume}"| sed -nr 's/^0000.*(sd[b-z]|xvd[b-z]).*/\1/p' || true)
    if [ ! -z "$${alias}" ]; then
      echo "---> create link from $${volume} to /dev/$${alias}"
      ln -s "$${volume}" "/dev/$${alias}"
    fi
  done
}


# Grab from here https://github.com/gruntwork-io/bash-commons/blob/master/modules/bash-commons/src/log.sh
# Log the given message at the given level. All logs are written to stderr with a timestamp.
function log {
  local -r level="$1"
  local -r message="$2"
  local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local -r script_name="$(basename "$0")"
  >&2 echo -e "$${timestamp} [$${level}] [$script_name] $${message}"
}

# Log the given message at INFO level. All logs are written to stderr with a timestamp.
function log_info {
  local -r message="$1"
  log "INFO" "$message"
}

# Log the given message at WARN level. All logs are written to stderr with a timestamp.
function log_warn {
  local -r message="$1"
  log "WARN" "$message"
}

# Log the given message at ERROR level. All logs are written to stderr with a timestamp.
function log_error {
  local -r message="$1"
  log "ERROR" "$message"
}


# Grab from here https://github.com/gruntwork-io/terraform-aws-influx/blob/master/modules/influxdb-commons/mount-volume.sh
# This method is used to configure a new EBS volume. It formats the specified device name using ext4 and mounts it at
# the given mount point, with the given OS user as owner.
function mount_volume {
  local -r device_name="$1"
  local -r mount_point="$2"
  local -r file_system_type="$${3:-ext4}"
  local -r mount_options="$${4:-defaults,nofail}"
  local -r fs_tab_path="/etc/fstab"

  case "$file_system_type" in
    "ext4")
      log_info "Creating $file_system_type file system on $device_name..."
      mkfs.ext4 -F "$device_name"
      ;;
    "xfs")
      log_info "Creating $file_system_type file system on $device_name..."
      mkfs.xfs -f "$device_name"
      ;;
    *)
      log_error "The file system type '$file_system_type' is not currently supported by this script."
      exit 1
  esac

  log_info "Creating mount point $mount_point..."
  mkdir -p "$mount_point"

  log_info "Get volume UUID..."
  local -r volume_uuid=$(blkid -s UUID -o value $${device_name})

  log_info "Adding device $device_name to $fs_tab_path with mount point $mount_point..."
  echo "UUID=$volume_uuid       $mount_point   $file_system_type    $mount_options  0 2" >> "$fs_tab_path"

  log_info "Mounting volumes..."
  mount -a
}


# Adapt from here https://github.com/gruntwork-io/terraform-aws-influx/blob/master/examples/tick-single-cluster/user-data/user-data.sh
function mount_volumes {
  local -r volume_device_name="$1"
  local -r volume_mount_point="$2"
  local -r volume_owner="$3"

  if [ -z "$${volume_device_name}" ] || [ -z "$${volume_mount_point}" ]; then
    echo "No volume to mount"
    exit 0
  fi

  echo "Create a temporary symbolic link to retrieve UUID on first boot"
  nvme_alias

  echo "Mounting EBS Volume for meta, data, wal and hh directories"
  mount_volume "$volume_device_name" "$volume_mount_point" "$volume_owner"
}


mount_volumes \
  "${ebs_volume_device_name}" \
  "${ebs_volume_mount_point}"
