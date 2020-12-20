# AWS Infrastructure provisioning via Terraform
## Prerequisites
* Download Terraform CLI ([v0.14.3](https://releases.hashicorp.com/terraform/0.14.3/)) and move the binary to a PATH directory on your local machine (ex. /usr/local/bin)
* Execute `terraform -v` and validate the output matches: `Terraform v0.14.3`
* Verify aws credentials are set correctly on your local machine so terraform can use them
  * You can execute `aws sts get-caller-identity` to verify which account & user you have set by default
  * If you'd like to use a different aws profile you can update `terraform.tfvars` with `aws_profile = <YOUR AWS PROFILE>`

## Customize
You can create your own .tfvars file to override default variables set in `variables.tf`. There's a file, `dev-us-east-1.tfvars` that's been created to illustrate how customizations can be made to the deployment. To use the .tfvars file you would specify the file name in the terraform cli `-var-file` option.

## View the Terraform plan
* `terraform init`
* `terraform plan -var-file dev-us-east-1.tfvars` (Note: You can create your own .tfvars file to specify here)

## Deploy the Infrastructure
* `terraform apply -var-file dev-us-east-1.tfvars` (Note: Specify your .tfvars file)
* After receiving the prompt for applying the changes, review that the infrastructure changes look correct then enter `yes`

## Destroy the Infrastructure
* `terraform destroy -var-file dev-us-east-1.tfvars` (Note: Specify your .tfvars file)

## State Management
Terraform creates state files to store bindings between objects in a remote system and resource instances declared in your configuration. By default, if no custom state configuration is created terraform will create a `terraform.tfstate` file to record state. In `main.tf` there's a commented block where you can specify an s3 location to store & manage your statefile *(recommended)*. Go to the [terraform doc on state](https://www.terraform.io/docs/state/index.html) to learn more.