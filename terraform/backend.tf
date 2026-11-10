terraform {
  backend "s3" {
    bucket         = "divya-tstate1325"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    use_lockfile   = true
    encrypt        = true
  }
}