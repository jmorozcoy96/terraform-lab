output "cluster_id" {
  description = "ID del cluster EMR"
  value       = aws_emr_cluster.this.id
}

output "master_public_dns" {
  description = "DNS público del master"
  value       = aws_emr_cluster.this.master_public_dns
}

output "logs_bucket" {
  description = "Bucket S3 donde se guardan los logs del cluster"
  value       = aws_s3_bucket.emr_logs.bucket
}

