provider "aws" {
  region = "us-east-1"
}


resource "aws_s3_bucket" "terraform_state" {
  bucket = "akash-medusa-terraform-state-bucket"


  versioning {
    enabled = true
  }


  lifecycle {
    prevent_destroy = true
  }


  tags = {
    Name = "Terraform State Bucket"
    Environment = "prod"
  }
}


resource "aws_dynamodb_table" "terraform_locks" {
  name = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"


  attribute {
    name = "LockeID"
    type = "S"
  }


  tags = {
    Name = "Terraform Lock Table"
  }
}
