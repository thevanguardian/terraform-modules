locals {
  create_lambda = var.reuse_lambda_arn == "" ? true : false
  # schedule_expression = "rate(${var.ttl} hour${var.ttl == 1 ? "" : "s"})"

  ttl_execution_time  = timeadd(timestamp(), "${var.ttl}h")
  schedule_expression = formatdate("cron(%M %H %d %m ? %Y)", local.ttl_execution_time)
}
variable "identifier" {
  description = "A unique identifier for the jump box, used to create unique resource names."
  type        = string
  default     = "jump-box"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.identifier))
    error_message = "The identifier must be lowercase alphanumeric characters or hyphens."
  }
}
variable "vpc_id" {
  description = "The ID of the VPC where the jump box will be deployed."
  type        = string

  validation {
    condition     = can(regex("^vpc-([0-9a-f]{8}|[0-9a-f]{17})$", var.vpc_id))
    error_message = "The vpc_id must be a valid VPC ID, e.g., vpc-xxxxxxxx or vpc-xxxxxxxxxxxxxxxxx."
  }
}
variable "subnet_id" {
  description = "The subnet ID where the jump box will be deployed."
  type        = string

  validation {
    condition     = can(regex("^subnet-([0-9a-f]{8}|[0-9a-f]{17})$", var.subnet_id))
    error_message = "The subnet_id must be a valid Subnet ID, e.g., subnet-xxxxxxxx or subnet-xxxxxxxxxxxxxxxxx."
  }
}
variable "instance_type" {
  description = "The type of EC2 instance to use for the jump box."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^[a-z0-9]+\\.[a-z0-9]+$", var.instance_type))
    error_message = "The instance_type must be a valid EC2 instance type, e.g., t3.micro."
  }
}
variable "ami_config" {
  description = "A map of AMI configuration options (owner, name, filters)."
  type = object({
    owner   = list(string)
    name    = string
    filters = map(string)
  })
  default = {
    owner   = ["amazon"]
    name    = "amzn2-ami-hvm-*-x86_64-gp2"
    filters = { state = "available" }
  }
}
variable "ttl" {
  description = "The time-to-live (TTL) for the jump box in hours."
  type        = number
  default     = 8

  validation {
    condition     = var.ttl > 0
    error_message = "The ttl must be a positive number representing hours."
  }
}
variable "create_temp_iam_user" {
  description = "Whether to create a temporary IAM user for the jump box."
  type        = bool
  default     = true
}
variable "create_ssm_role" {
  description = "Whether to create an IAM role for SSM access."
  type        = bool
  default     = true
}
variable "security_group_ids" {
  description = "A list of security group IDs to associate with the jump box."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for id in var.security_group_ids : can(regex("^sg-([0-9a-f]{8}|[0-9a-f]{17})$", id))
    ])
    error_message = "Each security_group_id must be a valid Security Group ID, e.g., sg-xxxxxxxx or sg-xxxxxxxxxxxxxxxxx."
  }
}
variable "storage_size" {
  description = "The size of the root EBS volume in GB."
  type        = number
  default     = 8

  validation {
    condition     = var.storage_size >= 8
    error_message = "The storage_size must be at least 8 GB."
  }
}
variable "storage_type" {
  description = "The type of the root EBS volume (e.g., gp2, gp3, io1, st1)."
  type        = string
  default     = "gp3"

  validation {
    condition     = can(regex("^(gp2|gp3|io1|io2|st1|sc1)$", var.storage_type))
    error_message = "The storage_type must be one of: gp2, gp3, io1, io2, st1, sc1."
  }
}
variable "instance_profile" {
  description = "The name of an existing IAM instance profile to attach to the jump box. If not set, a new one may be created."
  type        = string
  default     = ""

  validation {
    condition     = var.instance_profile == "" || can(regex("^[a-zA-Z0-9+=,.@_-]+$", var.instance_profile))
    error_message = "The instance_profile must be empty or a valid IAM instance profile name."
  }

  validation {
    condition     = var.create_ssm_role || var.instance_profile != ""
    error_message = "Set instance_profile when create_ssm_role is false."
  }
}

variable "teardown_action" {
  description = "Action for TTL enforcement: stop leaves the instance for later inspection; terminate deletes it."
  type        = string

  validation {
    condition     = contains(["stop", "terminate"], var.teardown_action)
    error_message = "teardown_action must be one of: stop, terminate."
  }
}
