run "test_ami_id_output" {
  command = plan

  variables {
    identifier = "test-jump-box"
    vpc_id     = "vpc-12345678"
    subnet_id  = "subnet-12345678"
  }

  assert {
    condition     = output.ami_id != ""
    error_message = "AMI ID output must not be empty"
  }
}

run "test_instance_attributes" {
  command = plan

  variables {
    identifier = "test-jump-box"
    vpc_id     = "vpc-12345678"
    subnet_id  = "subnet-12345678"
  }

  assert {
    condition     = can(output.instance_attributes.id)
    error_message = "Instance ID must be present in attributes"
  }
}
