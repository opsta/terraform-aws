# Sonarqube Example

This folder shows an example of Terraform code that uses the [instance](https://github.com/opsta/terraform-aws/tree/master/modules/instance) module to deploy a [Sonarqube](https://www.sonarqube.org) instance in [AWS](https://aws.amazon.com/).

## What resources does this example deploy

1. A single _all in one server_ [Sonarqube](https://www.sonarqube.org)

## Quick start

To deploy a Sonarqube instance:

1. Install [Terraform](https://www.terraform.io/).
1. Copy this example folder on your forked [Opsta Playbooks](https://github.com/opsta/opsta-playbook) in the `terraforms/sonarqube/` directory.
1. Open the `variables.tf` file in this folder, set the environment variables specified at the top of the file, and fill in any other variables that don't have a default and the one you want to override.
1. Run below command

```bash
# Create Sonarqube Instance
cd terraforms/sonarqube/
export AWS_ACCESS_KEY_ID=MYACCESSKEY
export AWS_SECRET_ACCESS_KEY=CHANGEME
terraform init
terraform apply

cd ../../
ansible-playbook -i terraforms/sonarqube/inventories/sonarqube.ini \
  host-preparation-ubuntu.yml install-cfupdate.yml install-letsencrypt.yml install-sonarqube.yml
```
