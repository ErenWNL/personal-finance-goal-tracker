locals {
  name = var.project
  tags = { Project = var.project }
}

# --- VPC ---
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"

  name = local.name
  cidr = "10.20.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.20.1.0/24", "10.20.2.0/24"]
  public_subnets  = ["10.20.11.0/24", "10.20.12.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.tags
}

# --- EKS Cluster ---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.8.0"

  name               = "${local.name}-eks"
  kubernetes_version = "1.30"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  endpoint_public_access = true
  enable_irsa            = true

  # prevent long name_prefix errors
  iam_role_use_name_prefix = false
  iam_role_name            = "pfgt-eks-cluster-role"

  eks_managed_node_groups = {
    default = {
      desired_size   = 1
      min_size       = 1
      max_size       = 1
      instance_types = ["t3.micro", "t2.micro"] # free-tier eligible
      capacity_type  = "ON_DEMAND"
      ami_type       = "AL2_x86_64"
      disk_size      = 20
    }
  }

  tags = local.tags
}

# --- RDS MySQL (Free-tier friendly) ---
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.13.1"

  identifier           = "${local.name}-mysql"
  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0"
  major_engine_version = "8.0"

  # FREE TIER SIZES
  instance_class        = "db.t3.micro"
  allocated_storage     = 20 # free tier covers up to 20GB
  max_allocated_storage = 20

  db_name  = "primary_db"
  username = var.db_username
  password = var.db_password
  port     = 3306

  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_ids             = module.vpc.private_subnets

  publicly_accessible = false
  deletion_protection = false
  skip_final_snapshot = true

  tags = local.tags
}

# --- S3 bucket ---
resource "random_id" "suffix" { byte_length = 2 }

resource "aws_s3_bucket" "assets" {
  bucket = "${local.name}-assets-${random_id.suffix.hex}"
  tags   = local.tags
}

# --- ECR repositories ---
resource "aws_ecr_repository" "repos" {
  for_each = toset([
    "api-gateway",
    "authentication-service",
    "user-finance-service",
    "goal-service",
    "insight-service",
    "frontend"
  ])
  name = "${local.name}/${each.key}"

  image_scanning_configuration { scan_on_push = true }
  image_tag_mutability = "MUTABLE"
  tags                 = local.tags
}

# --- Secrets Manager for app creds ---
resource "aws_secretsmanager_secret" "app" {
  name = "${local.name}/app"
  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "app_v1" {
  secret_id = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({
    MYSQL_HOST = module.db.db_instance_address
    MYSQL_PORT = "3306"
    MYSQL_USER = var.db_username
    MYSQL_PASS = var.db_password
    AUTH_DB    = "auth_service_db"
    FINANCE_DB = "user_finance_db"
    GOAL_DB    = "goal_service_db"
    INSIGHT_DB = "insight_service_db"
    S3_BUCKET  = aws_s3_bucket.assets.bucket
  })
}