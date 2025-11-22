resource "aws_instance" "this" {
  ami                    = data.aws_ami.this.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = length(var.security_group_ids) > 0 ? var.security_group_ids : [aws_security_group.this.id]

  root_block_device {
    volume_size           = var.storage_size
    volume_type           = var.storage_type
    delete_on_termination = true
  }

  iam_instance_profile = var.create_ssm_role ? aws_iam_instance_profile.ssm[0].name : var.instance_profile

  tags = {
    TTL             = tostring(var.ttl)
    SHUTDOWN_METHOD = var.teardown_action
    Name            = var.identifier
  }

  dynamic "instance_market_options" {
    for_each = var.spot_instance_config != null ? [1] : []
    content {
      market_type = "spot"
      spot_options {
        max_price                      = var.spot_instance_config.max_price
        instance_interruption_behavior = var.spot_instance_config.interruption_behavior
      }
    }
  }
}

resource "aws_security_group" "this" {
  name_prefix = "${var.identifier}-ssm"
  description = "Security group for SSM"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "this" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow outbound HTTPS for SSM"
  security_group_id = aws_security_group.this.id
}

resource "aws_iam_role" "ssm" {
  count = var.create_ssm_role ? 1 : 0

  name               = "${var.identifier}-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ssm_assume_role_policy.json

  tags = {
    Name = "${var.identifier}-ssm-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  count      = var.create_ssm_role ? 1 : 0
  role       = aws_iam_role.ssm[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  count = var.create_ssm_role ? 1 : 0
  name  = "${var.identifier}-ssm-profile"
  role  = aws_iam_role.ssm[0].name
}

resource "aws_iam_role" "automation" {
  name               = "${var.identifier}-automation"
  assume_role_policy = data.aws_iam_policy_document.automation_assume_role.json
}

resource "aws_iam_role_policy" "automation" {
  name   = "${var.identifier}-automation"
  role   = aws_iam_role.automation.name
  policy = data.aws_iam_policy_document.automation_policy.json
}

resource "aws_iam_role" "scheduler" {
  name               = "${var.identifier}-scheduler"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role_policy.json
}

resource "aws_iam_role_policy" "scheduler" {
  name   = "${var.identifier}-scheduler"
  role   = aws_iam_role.scheduler.name
  policy = data.aws_iam_policy_document.scheduler_policy.json
}

resource "aws_scheduler_schedule" "teardown" {
  name                = "${var.identifier}-teardown"
  state               = "ENABLED"
  schedule_expression = format("at(%s)", local.teardown_time)

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ssm:startAutomationExecution"
    role_arn = aws_iam_role.scheduler.arn

    input = jsonencode({
      DocumentName = local.teardown_document
      Parameters = {
        InstanceId           = [aws_instance.this.id]
        AutomationAssumeRole = [aws_iam_role.automation.arn]
      }
    })
  }
}
