terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-freetier"
    key = "wordpress/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-lock"
  }
}
