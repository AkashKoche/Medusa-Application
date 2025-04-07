terraform {
  backend "s3" {
    bucket         = "akash-medusa-terraform-state-bucket"
    key            = "env/prod/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}
