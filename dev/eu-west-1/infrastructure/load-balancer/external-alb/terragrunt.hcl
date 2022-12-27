include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git//?ref=v6.6.1"

  extra_arguments "init_args" {
    commands = [
      "init"
    ]

    arguments = [
    ]
  }

}

dependency "vpc" {
  config_path = "../../vpc"
  mock_outputs = {
    vpc_id = "vpc-00000000"
    public_subnets = ["subnet-00000000","subnet-00000001","subnet-00000002"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "external-security-group" {
  config_path = "../external-security-group/"
  mock_outputs = {
    security_group_id = "sg-sample-sg"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

# dependency "external-security-group" {
#   config_path = "../external-security-group/"
#   skip_outputs = true
# }

# dependencies {
#   paths = ["../..//vpc"]
# }

inputs = {
  name               = "external-alb"
  load_balancer_type = "application"
  vpc_id             = dependency.vpc.outputs.vpc_id
  subnets            = dependency.vpc.outputs.public_subnets
  security_groups    = [dependency.external-security-group.outputs.security_group_id]
  internal           = false
  target_groups = [
    {
      name             = "external-route-to-nothing"
      backend_protocol = "HTTP"
      backend_port     = 80
    }
  ]

  http_tcp_listeners = [
    {
      port               = "80"
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]


  tags = {
    Service     = "external-alb"
    Project     = "Terragrunt Medium"
    Environment = "Development"
  }
}