module "ephemeral-jump-box" {
  source     = "../"
  identifier = "test-jump-box"
  vpc_id     = "vpc-12345678"
  subnet_id  = "subnet-12345678"
}
