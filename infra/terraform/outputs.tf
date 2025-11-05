output "eks_cluster_name" { value = module.eks.cluster_name }
output "rds_endpoint" { value = module.db.db_instance_address }
output "s3_bucket" { value = aws_s3_bucket.assets.bucket }
output "ecr_repos" { value = { for k, v in aws_ecr_repository.repos : k => v.repository_url } }
