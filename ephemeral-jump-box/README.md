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
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.7.1 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.ttl_enforcer_schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.ttl_enforcer_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_instance_profile.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ttl_enforcer_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ttl_enforcer_lambda_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ssm_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ttl_enforcer_lambda_basic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_lambda_function.ttl_enforcer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.allow_eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [archive_file.ttl_enforcer_lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.ssm_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ttl_enforcer_lambda_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ttl_enforcer_lambda_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_config"></a> [ami\_config](#input\_ami\_config) | A map of AMI configuration options (owner, name, filters). | <pre>object({<br/>    owner   = list(string)<br/>    name    = string<br/>    filters = map(string)<br/>  })</pre> | <pre>{<br/>  "filters": {<br/>    "state": "available"<br/>  },<br/>  "name": "amzn2-ami-hvm-*-x86_64-gp2",<br/>  "owner": [<br/>    "amazon"<br/>  ]<br/>}</pre> | no |
| <a name="input_create_ssm_role"></a> [create\_ssm\_role](#input\_create\_ssm\_role) | Whether to create an IAM role for SSM access. | `bool` | `true` | no |
| <a name="input_create_temp_iam_user"></a> [create\_temp\_iam\_user](#input\_create\_temp\_iam\_user) | Whether to create a temporary IAM user for the jump box. | `bool` | `true` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | A unique identifier for the jump box, used to create unique resource names. | `string` | `"jump-box"` | no |
| <a name="input_instance_profile"></a> [instance\_profile](#input\_instance\_profile) | The name of an existing IAM instance profile to attach to the jump box. If not set, a new one may be created. | `string` | `""` | no |
| <a name="input_instance_term_method"></a> [instance\_term\_method](#input\_instance\_term\_method) | The method to terminate the instance (e.g., 'terminate', 'stop'). | `string` | `"terminate"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of EC2 instance to use for the jump box. | `string` | `"t3.micro"` | no |
| <a name="input_reuse_lambda_arn"></a> [reuse\_lambda\_arn](#input\_reuse\_lambda\_arn) | The ARN of an existing Lambda function to reuse for cleanup. If not set, a new Lambda function will be created. | `string` | `""` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | A list of security group IDs to associate with the jump box. | `list(string)` | `[]` | no |
| <a name="input_spot_instance_config"></a> [spot\_instance\_config](#input\_spot\_instance\_config) | A map of spot instance configuration options (e.g., max\_price, interruption\_behavior). Leave empty for on-demand. | `map(string)` | <pre>{<br/>  "interruption_behavior": "terminate",<br/>  "max_price": 0.23<br/>}</pre> | no |
| <a name="input_storage_size"></a> [storage\_size](#input\_storage\_size) | The size of the root EBS volume in GB. | `number` | `8` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | The type of the root EBS volume (e.g., gp2, gp3, io1, st1). | `string` | `"gp3"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet ID where the jump box will be deployed. | `string` | n/a | yes |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | The time-to-live (TTL) for the jump box in hours. | `number` | `8` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the jump box will be deployed. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | The ID of the selected AMI |
| <a name="output_instance_attributes"></a> [instance\_attributes](#output\_instance\_attributes) | A map of basic attributes for the EC2 instance |
<!-- END_TF_DOCS -->