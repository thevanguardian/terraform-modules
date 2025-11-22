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

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  ssm_automation_documents = [
    "AWS-StopEC2Instance",
    "AWS-TerminateEC2Instance",
  ]
}

data "aws_iam_policy_document" "ssm_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "automation_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "automation_policy" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:TerminateInstances",
      "ec2:StopInstances"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "scheduler_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "scheduler_policy" {
  statement {
    actions = ["ssm:StartAutomationExecution"]
    resources = [
      for name in local.ssm_automation_documents :
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:automation-definition/${name}:*"
    ]
  }
}
