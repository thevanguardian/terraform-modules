data "aws_ami" "this" {
  most_recent = true
  owners = var.ami_owner

  filter {
    name   = "name"
    values = [var.ami_name]
  }

  dynamic "filter" {
    for_each = var.ami_filters
    content {
      name   = filter.key
      values = [filter.value]
    }
  }
}