# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "iotcore-test-vpc"
  cidr = "20.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
  private_subnets = ["20.0.1.0/24", "20.0.2.0/24", "20.0.3.0/24"]
  public_subnets  = ["20.0.101.0/24", "20.0.102.0/24", "20.0.103.0/24"]

  enable_nat_gateway = false

  tags = var.default_tags
}
