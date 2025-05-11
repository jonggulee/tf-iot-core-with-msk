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


# IAM policy
module "iam_policy_msk" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "iotcore-test-msk-policy"
  description = "IAM policy for IoT Core test"
  policy      = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:CreateNetworkInterfacePermission",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcs",
            "ec2:DescribeVpcAttribute",
            "ec2:DescribeSecurityGroups"
         ],
         "Resource": "*"
      },
      {
         "Effect": "Allow",
         "Action": [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
         ],
         "Resource": "arn:aws:secretsmanager:region:123456789012:secret:AmazonMSK_*"
      }
   ]
}
EOF

  tags = var.default_tags
}

# IAM Role
module "iam_role_msk" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  role_name             = "iotcore-test-msk-role"
  create_role           = true
  role_requires_mfa     = false
  trusted_role_services = ["iot.amazonaws.com"]
  trusted_role_actions  = ["sts:AssumeRole"]

  custom_role_policy_arns = [module.iam_policy_msk.arn]

  tags = var.default_tags
}
