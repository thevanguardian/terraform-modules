output "ami_id" {
  description = "The ID of the selected AMI"
  value       = data.aws_ami.this.id
}
output "instance_attributes" {
  description = "A map of basic attributes for the EC2 instance"
  value = {
    id         = aws_instance.this.id
    arn        = aws_instance.this.arn
    public_ip  = aws_instance.this.public_ip
    private_ip = aws_instance.this.private_ip
    state      = aws_instance.this.instance_state
  }
}
# output "lambda_arn" {
#   description = "The ARN of the Lambda function that terminates the instance after TTL"
#   value       = aws_lambda_function.this.arn
# }
