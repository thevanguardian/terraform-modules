output "ami_id" {
  description = "The ID of the selected AMI"
  value       = data.aws_ami.this.id
}
output "instance_attributes" {
  description = "A map of basic attributes for each EC2 instance"
  value = {
    for k, v in aws_instance.this : k => {
      id         = v.id
      arn        = v.arn
      public_ip  = v.public_ip
      private_ip = v.private_ip
      state      = v.instance_state
    }
  }
}
# output "lambda_arn" {
#   description = "The ARN of the Lambda function that terminates the instance after TTL"
#   value       = aws_lambda_function.this.arn
# }
