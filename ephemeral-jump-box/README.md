# terraform-aws-ephemeral-jump-box **v0.0.1**

An opinionated Terraform module that spins up an Amazon Linux jump box, wires it to AWS Systems Manager Session Manager, and schedules a one-time EventBridge/SSM automation run to stop or terminate it after a configurable TTL.
The design keeps the compute footprint short-lived, enforces tagging/SSM hardening, and exposes simple switches for teams that need auditable forensic windows (stop) or full teardown (terminate).

---

## Usage

```hcl
module "jump_box" {
  source = "git::https://gitlab.com/thevanguardian/terraform-modules.git//ephemeral-jump-box?ref=v0.0.1"

  identifier        = "audit-jumpbox"
  vpc_id            = "vpc-0123456789abcdef0"
  subnet_id         = "subnet-0123456789abcdef0"
  ttl               = 6
  teardown_action   = "terminate"
  security_group_ids = [
    "sg-0123456789abcdef0"
  ]
}
```

## Detailed example

```hcl
locals {
  auditors = ["alice@example.com", "bob@example.com"]
}

module "ephemeral_jump_box" {
  source = "git::https://gitlab.com/thevanguardian/terraform-modules.git//ephemeral-jump-box?ref=v0.0.1"

  identifier      = "ir-jumpbox"
  vpc_id          = module.shared_vpc.id
  subnet_id       = module.shared_vpc.private_subnet_ids[0]
  instance_type   = "t3.small"
  storage_size    = 30
  ttl             = 12                               # auto stop/terminate after 12h
  teardown_action = "stop"                           # keep the instance for IR evidence

  ami_owner  = ["amazon"]
  ami_name   = "amzn2-ami-hvm-*-x86_64-gp2"
  ami_filters = {
    virtualization-type = "hvm"
    architecture        = "x86_64"
  }

  security_group_ids = [
    aws_security_group.session_manager_access.id,
    aws_security_group.egress_to_tools.id,
  ]

  # Skip role creation and attach an existing profile that already grants Session Manager access
  create_ssm_role   = false
  instance_profile  = aws_iam_instance_profile.jump_box.name

}

output "jump_box_ami" {
  description = "AMI that backed the ephemeral jump box"
  value       = module.ephemeral_jump_box.ami_id
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
| [aws_iam_instance_profile.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.automation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.automation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ssm_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_scheduler_schedule.teardown](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.automation_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.automation_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scheduler_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scheduler_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssm_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_filters"></a> [ami\_filters](#input\_ami\_filters) | A map of additional filters to apply when searching for the AMI. | `map(string)` | <pre>{<br/>  "state": "available"<br/>}</pre> | no |
| <a name="input_ami_name"></a> [ami\_name](#input\_ami\_name) | The name of the AMI to use for the jump box. | `string` | `"amzn2-ami-hvm-*-x86_64-gp2"` | no |
| <a name="input_ami_owner"></a> [ami\_owner](#input\_ami\_owner) | A list of AMI owners (AWS account IDs or 'amazon') to use for the jump box. | `list(string)` | <pre>[<br/>  "amazon"<br/>]</pre> | no |
| <a name="input_create_ssm_role"></a> [create\_ssm\_role](#input\_create\_ssm\_role) | Whether to create an IAM role for SSM access. | `bool` | `true` | no |
| <a name="input_create_temp_iam_user"></a> [create\_temp\_iam\_user](#input\_create\_temp\_iam\_user) | Whether to create a temporary IAM user for the jump box. | `bool` | `true` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | A unique identifier for the jump box, used to create unique resource names. | `string` | `"jump-box"` | no |
| <a name="input_instance_profile"></a> [instance\_profile](#input\_instance\_profile) | The name of an existing IAM instance profile to attach to the jump box. If not set, a new one may be created. | `string` | `""` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of EC2 instance to use for the jump box. | `string` | `"t3.micro"` | no |
| <a name="input_reuse_lambda_arn"></a> [reuse\_lambda\_arn](#input\_reuse\_lambda\_arn) | The ARN of an existing Lambda function to reuse for cleanup. If not set, a new Lambda function will be created. | `string` | `""` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | A list of security group IDs to associate with the jump box. | `list(string)` | `[]` | no |
| <a name="input_spot_instance_config"></a> [spot\_instance\_config](#input\_spot\_instance\_config) | A map of spot instance configuration options (e.g., max\_price, interruption\_behavior). Leave empty for on-demand. | `map(string)` | <pre>{<br/>  "interruption_behavior": "terminate",<br/>  "max_price": 0.23<br/>}</pre> | no |
| <a name="input_storage_size"></a> [storage\_size](#input\_storage\_size) | The size of the root EBS volume in GB. | `number` | `8` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | The type of the root EBS volume (e.g., gp2, gp3, io1, st1). | `string` | `"gp3"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet ID where the jump box will be deployed. | `string` | n/a | yes |
| <a name="input_teardown_action"></a> [teardown\_action](#input\_teardown\_action) | Action for TTL enforcement: stop leaves the instance for later inspection; terminate deletes it. | `string` | n/a | yes |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | The time-to-live (TTL) for the jump box in hours. | `number` | `8` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the jump box will be deployed. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | The ID of the selected AMI |
| <a name="output_instance_attributes"></a> [instance\_attributes](#output\_instance\_attributes) | A map of basic attributes for the EC2 instance |
<!-- END_TF_DOCS -->
