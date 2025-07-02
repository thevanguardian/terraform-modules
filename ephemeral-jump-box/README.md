# terraform-aws-ephemeral-jump-box **v0.0.1**

A plug-and-play module that lets teams spin up a hardened, temporary bastion host (SSM-managed) on demand and auto-tears it down after a configurable TTL.
Perfect for auditors, responders, or contractors who need just-in-time shell access to private subnets without leaving long-lived instances hanging around.

---

## Usage

```hcl
module "widget" {
  source = "git::https://github.com/your-org/terraform-aws-super-widget.git?ref=v0.0.0"

  # module inputs …
  name        = "demo"
  environment = "dev"
} 
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_filters"></a> [ami\_filters](#input\_ami\_filters) | A map of additional filters to apply when searching for the AMI. | `map(string)` | <pre>{<br/>  "state": "available"<br/>}</pre> | no |
| <a name="input_ami_name"></a> [ami\_name](#input\_ami\_name) | The name of the AMI to use for the jump box. | `string` | `"amzn2-ami-hvm-*-x86_64-gp2"` | no |
| <a name="input_ami_owner"></a> [ami\_owner](#input\_ami\_owner) | A list of AMI owners (AWS account IDs or 'amazon') to use for the jump box. | `list(string)` | <pre>[<br/>  "amazon"<br/>]</pre> | no |
| <a name="input_create_temp_iam_user"></a> [create\_temp\_iam\_user](#input\_create\_temp\_iam\_user) | Whether to create a temporary IAM user for the jump box. | `bool` | `true` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of EC2 instance to use for the jump box. | `string` | `"t3.micro"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | A list of security group IDs to associate with the jump box. | `list(string)` | `[]` | no |
| <a name="input_storage_size"></a> [storage\_size](#input\_storage\_size) | The size of the root EBS volume in GB. | `number` | `8` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet ID where the jump box will be deployed. | `string` | n/a | yes |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | The time-to-live (TTL) for the jump box in hours. | `number` | `8` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the jump box will be deployed. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | The ID of the selected AMI |
<!-- END_TF_DOCS -->