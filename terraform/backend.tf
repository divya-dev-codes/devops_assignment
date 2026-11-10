terraform {
  backend "s3" {
    bucket         = "devops-assignment-tfstate"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}