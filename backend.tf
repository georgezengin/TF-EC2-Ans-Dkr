# uncomment next lines to set backend to local, then run 'terraform init -migrate-state' on your CLI
terraform {
  backend "local" {
    path = "terraform.tfstate" 
  } 
}

# to enable s3 bucket, uncomment next blocks and replace name of bucket to your own created bucket
# also set name of bucket in variables.tf file
# terraform {
#   backend "s3" {
#     bucket         = "terraform-s3-state-gz"
#     key            = "terraform.tfstate"
#     region         = "eu-central-1"
#     dynamodb_table = "tfstates-locks"

#     ## Replace this with your bucket name!
#     ##    bucket         = "${var.v_s3_tfstate_bucket}"
#     ##    key            = "${local.state_file_name}"
#     ##    region         = "${var.v_aws_region}"

#     encrypt        = true
#   }
# }

# resource "aws_s3_bucket_versioning" "enabled" {
#   bucket = var.v_s3_tfstate_bucket
#   versioning_configuration {
#     status = "Enabled"
#   }
# }
# resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
#   bucket = var.v_s3_tfstate_bucket
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# resource "aws_s3_bucket_public_access_block" "public_access" {
#   bucket                  = var.v_s3_tfstate_bucket
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# resource "aws_dynamodb_table" "terraform_states_locks" {
#   name         = "tfstates-locks"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }
