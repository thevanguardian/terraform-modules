resource "aws_instance" "this" {
  for_each               = toset(var.instance_identifiers)
  ami                    = data.aws_ami.this.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  root_block_device {
    volume_size           = var.storage_size
    volume_type           = var.storage_type
    delete_on_termination = true
  }

  iam_instance_profile = var.create_ssm_role ? aws_iam_instance_profile.ssm[0].name : var.instance_profile

  tags = {
    TTL             = tostring(var.ttl)
    SHUTDOWN_METHOD = var.instance_term_method
    Name            = "${var.identifier}-${each.key}"
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

resource "aws_lambda_function" "ttl_enforcer" {
  filename         = data.archive_file.ttl_enforcer_lambda.output_path
  function_name    = "${var.identifier}-ttl-enforcer"
  role             = aws_iam_role.ttl_enforcer_lambda.arn
  handler          = "ttl_enforcer.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.ttl_enforcer_lambda.output_base64sha256

  environment {
    variables = {
      TTL             = var.ttl
      SHUTDOWN_METHOD = var.instance_term_method
    }
  }

  tags = {
    Name = "${var.identifier}-ttl-enforcer"
  }
}

resource "aws_iam_role" "ttl_enforcer_lambda" {
  name = "${var.identifier}-ttl-enforcer-lambda-role"

  assume_role_policy = data.aws_iam_policy_document.ttl_enforcer_lambda_assume.json

  tags = {
    Name = "${var.identifier}-ttl-enforcer-lambda-role"
  }
}

data "aws_iam_policy_document" "ttl_enforcer_lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ttl_enforcer_lambda_basic" {
  role       = aws_iam_role.ttl_enforcer_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "ttl_enforcer_lambda_ec2" {
  name = "${var.identifier}-ttl-enforcer-ec2-policy"
  role = aws_iam_role.ttl_enforcer_lambda.id

  policy = data.aws_iam_policy_document.ttl_enforcer_lambda_ec2.json
}

resource "aws_cloudwatch_event_rule" "ttl_enforcer_schedule" {
  name                = "${var.identifier}-ttl-enforcer-schedule"
  schedule_expression = local.schedule_expression
}

resource "aws_cloudwatch_event_target" "ttl_enforcer_lambda" {
  for_each  = toset(var.instance_identifiers)
  rule      = aws_cloudwatch_event_rule.ttl_enforcer_schedule.name
  target_id = "ttl-enforcer: ${each.key}"
  arn       = aws_lambda_function.ttl_enforcer.arn

  input = jsonencode({
    instance_id     = aws_instance.this[each.key].id
    ttl             = var.ttl
    shutdown_method = var.instance_term_method
  })
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ttl_enforcer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ttl_enforcer_schedule.arn
}
