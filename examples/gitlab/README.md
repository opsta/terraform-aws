# GitLab Example

This folder shows an example of Terraform code that uses the [gitlab](https://github.com/opsta/terraform-aws/tree/master/modules/gitlab) module to deploy a [GitLab](https://gitlab.com) cluster in [AWS](https://aws.amazon.com/).

## What resources does this example deploy

1. A single _all in one server_ [GitLab](/modules/gitlab)

## Quick start

To deploy a GitLab instance:

1. Install [Terraform](https://www.terraform.io/).
1. Copy this example folder on your forked [Opsta Playbooks](https://github.com/opsta/opsta-playbook) in the `terraforms/gitlab/` directory.
1. Open the `variables.tf` file in this folder, set the environment variables specified at the top of the file, and fill in any other variables that don't have a default.
1. Run below command

```bash
# Create GitLab Instance
cd terraforms/gitlab/
export AWS_ACCESS_KEY_ID=MYACCESSKEY
export AWS_SECRET_ACCESS_KEY=CHANGEME
terraform init
terraform apply

cd ../../
ansible-playbook -i terraforms/gitlab/inventories/gitlab.ini \
  host-preparation-ubuntu.yml install-letsencrypt.yml install-gitlab.yml
```
