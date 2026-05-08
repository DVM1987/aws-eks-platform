output "tfstate_bucket" {
  description = "S3 bucket name for storing Terraform state files"
  value       = aws_s3_bucket.tfstate.id
}

output "tfstate_lock_table" {
  description = "DynamoDB table name for Terraform state locking"
  value       = aws_dynamodb_table.tfstate_lock.name
}

output "region" {
  description = "AWS region where state backend lives"
  value       = "ap-southeast-1"
}
