output "instance_attributes" {
  description = "Basic attributes for the jump box instance"
  value = {
    arn        = aws_instance.this.arn
    id         = aws_instance.this.id
    private_ip = aws_instance.this.private_ip
    public_ip  = aws_instance.this.public_ip
    state      = aws_instance.this.instance_state
  }
}
