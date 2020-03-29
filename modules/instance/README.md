# Opsta AWS Instance

This folder contains a [Terraform](https://www.terraform.io/) module to create instance(s) with most default value we used in Opsta on [AWS](https://aws.amazon.com/).

## How do you use this module

This folder defines a [Terraform module](https://www.terraform.io/docs/modules/usage.html), which you can use in your
code by adding a `module` configuration and setting its `source` parameter to URL of this folder:

```hcl
module "opsta_aws_instance" {
  source = "github.com/opsta/terraform-aws//modules/instance?ref=master"
  # ... See variables.tf for the other parameters you must define for the AWS instance module
}
```

Note the following parameters:

* `source`: Use this parameter to specify the URL of the instance module. The double slash (`//`) is intentional and required. Terraform uses it to specify subfolders within a Git repo (see [module sources](https://www.terraform.io/docs/modules/sources.html)). The `ref` parameter specifies a specific Git tag in this repo. That way, instead of using the latest version of this module from the `master` branch, which will change every time you run Terraform, you're using a fixed version of the repo.

You can find the other parameters in [variables.tf](variables.tf).

Check out the [examples folder](/examples/instance/) for fully-working sample code.

### EBS Volumes

This module create an [EBS volume](https://aws.amazon.com/ebs/) to store instance data. Default will create 40GB disk.

### Security Group

EC2 Instance has a Security Group that allows minimal connectivity:

* All outbound requests
* Inbound SSH, HTTP and HTTPS access from the world

### SSH access

You can associate an [EC2 Key Pair](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) with EC2 Instances in this cluster by specifying the Key Pair's name in the `ssh_key_name` variable. If you don't want to associate a Key Pair with these servers, set `ssh_key_name` to an empty string.
