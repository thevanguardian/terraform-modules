data "aws_ami" "this" {
  most_recent = true
  owners      = var.ami_config.owner

  filter {
    name   = "name"
    values = [var.ami_config.name]
  }

  dynamic "filter" {
    for_each = var.ami_config.filters != null ? var.ami_config.filters : {}
    content {
      name   = filter.key
      values = [filter.value]
    }
  }
}
data "aws_iam_policy_document" "ssm_assume_role_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "archive_file" "ttl_enforcer_lambda" {
  type        = "zip"
  source_file = "${path.module}/src/ttl_enforcer.py"
  output_path = "${path.module}/ttl_enforcer_lambda.zip"
}

data "aws_iam_policy_document" "ttl_enforcer_lambda_ec2" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances"
    ]
    # Dynamically include all instance ARNs
    resources = [for instance in aws_instance.this : instance.arn]
  }
}
