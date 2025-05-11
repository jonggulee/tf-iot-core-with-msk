# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "iotcore-test-vpc"
  cidr = "20.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["20.0.1.0/24", "20.0.2.0/24"]
  public_subnets  = ["20.0.101.0/24", "20.0.102.0/24"]

  enable_nat_gateway = false

  tags = var.default_tags
}


# IAM policy
module "iam_policy_msk" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "iotcore-test-policy"
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
         "Resource": "arn:aws:secretsmanager:*:*:secret:AmazonMSK_*"
      }
   ]
}
EOF

  tags = var.default_tags
}

# IAM Role
module "iam_role_msk" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  role_name             = "iotcore-test-role"
  create_role           = true
  role_requires_mfa     = false
  trusted_role_services = ["iot.amazonaws.com"]
  trusted_role_actions  = ["sts:AssumeRole"]

  custom_role_policy_arns = [module.iam_policy_msk.arn]

  tags = var.default_tags
}

# Customer Managed Key
module "cmk_msk" {
  source = "terraform-aws-modules/kms/aws"

  aliases     = ["iotcore/msk/test"]
  description = "KMS key for IoT Core test"
  key_usage   = "ENCRYPT_DECRYPT"
  key_users   = [module.iam_role_msk.iam_role_arn]

  tags = var.default_tags
}

# Secrets Manager
module "secrets_manager_msk" {
  source = "terraform-aws-modules/secrets-manager/aws"

  name        = "AmazonMSK_iotcore_test"
  description = "Secret for IoT Core test"

  secret_string = jsonencode({
    username = "iotcore-test"
    password = "iotcore-test-password"
  })

  kms_key_id = module.cmk_msk.key_id

  tags = var.default_tags
}

# Security Group
module "security_group_msk" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "iotcore-test-msk-sg"
  description = "Security group for IoT Core test"
  vpc_id      = module.vpc.vpc_id

  tags = var.default_tags
}

module "security_group_iotcore" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "iotcore-test-iotcore-sg"
  description = "Security group for IoT Core test"
  vpc_id      = module.vpc.vpc_id

  tags = var.default_tags
}

# MSK
module "msk_cluster" {
  source = "terraform-aws-modules/msk-kafka-cluster/aws"

  name                   = "iotcore-test-msk-cluster"
  kafka_version          = "3.6.0"
  number_of_broker_nodes = 2

  broker_node_client_subnets  = module.vpc.private_subnets
  broker_node_instance_type   = "kafka.t3.small"
  broker_node_security_groups = [module.security_group_msk.security_group_id]
  broker_node_storage_info = {
    ebs_storage_info = { volume_size = 10 }
  }

  client_authentication = {
    sasl = {
      scram = true
    }
  }

  create_scram_secret_association          = true
  scram_secret_association_secret_arn_list = [module.secrets_manager_msk.secret_arn]

  tags = var.default_tags

  depends_on = [module.secrets_manager_msk, module.security_group_msk]
}
