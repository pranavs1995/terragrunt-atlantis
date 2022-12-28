include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../../modules//web-server"

  extra_arguments "init_args" {
    commands = [
      "init"
    ]

    arguments = [
    ]
  }

}

dependency "vpc" {
  config_path = "../../infrastructure/vpc"
  mock_outputs = {
    azs = "sg-sample-sg"
    vpc_id = "vpc-00000000"
    private_subnets = ["subnet-10000000","subnet-20000001","subnet-30000002"]
    public_subnets = ["subnet-00000000","subnet-00000001","subnet-00000002"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "external_alb" {
  config_path = "../../infrastructure/load-balancer/external-alb"
  mock_outputs = {
    http_tcp_listener_arns = ["arn:aws:elasticloadbalancing:eu-west-1:000000000000:listener/abcxyz"]
    lb_dns_name = "qwerty123456.eu-west-1.elb.amazonaws.com"
    lb_zone_id = "zone0000000"
    target_group_arns = ["arn:aws:elasticloadbalancing:eu-west-1:000000000000:targetgroup/qwerty"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "external_security_group" {
  config_path = "../../infrastructure/load-balancer/external-security-group"
  mock_outputs = {
    security_group_id = "sg-sample-sg"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

# dependencies {
#   paths = ["../../infrastructure//vpc", "../../infrastructure/load-balancer/external-alb", "../../infrastructure/load-balancer/external-security-group"]
# }

inputs = {

  # VPC
  available_zones    = dependency.vpc.outputs.azs
  vpc_id             = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.vpc.outputs.private_subnets
  public_subnet_ids  = dependency.vpc.outputs.public_subnets

  # Set Inputs
  company_name     = "change-to-company-name"
  lb_ingress_rules = ["103.59.74.173/32"]
  project_name     = "Terragrunt Medium"

  # listener configuration 
  external_lb_security_group_id = dependency.external_security_group.outputs.security_group_id
  external_lb_listener_arn      = dependency.external_alb.outputs.http_tcp_listener_arns[0]
  external_lb_name              = dependency.external_alb.outputs.lb_dns_name
  external_lb_zone_id           = dependency.external_alb.outputs.lb_zone_id
  external_target_group_arns    = dependency.external_alb.outputs.target_group_arns

  environment = "tools-eu-1"

  tags = {
    Name        = "Terragrunt-VPC"
    Owner       = "Marcus"
    Contact     = "marcus.tse"
    Project     = "Terragrunt Medium"
    Environment = "Development"
  }
}