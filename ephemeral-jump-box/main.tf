resource "aws_instance" "this" {
  ami                    = data.aws_ami.this.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  root_block_device {
    volume_size           = var.storage_size
    volume_type           = "gp3"
    delete_on_termination = true
  }
  
  iam_instance_profile = var.create_ssm_role ? aws_iam_instance_profile.ssm[0].name : var.instance_profile

  tags = {
    TTL = tostring(var.ttl)
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

  name = "${var.identifier}-ssm-role"
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
