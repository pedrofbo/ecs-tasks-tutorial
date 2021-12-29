# Infrastructure management with Terraform

This module defines all the infrastructure necessary to this project.
It is managed using Terraform. See installation instructions and other
docs at https://www.terraform.io/docs.

## Input values
You will be prompted for `ec2_key_name`, `profile`, `region`. See
[docs](https://www.terraform.io/language/values/variables#assigning-values-to-root-module-variables)
for ways to assign these values. If no other method is used, you will
be prompted from the command line after running commands. These
variables mean:
- `ec2_key_name`: name of an (already existing on the deployment
account) EC2 key pair to be used to log in the created instances.
- `profile`: name of the awscli profile to be used to authenticate to
AWS.
[More on this](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html).
- `region`: AWS region where to create the resources.
