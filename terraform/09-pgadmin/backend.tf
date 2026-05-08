terraform {
  backend "s3" {
    bucket         = "muoidv-tfstate-527055790396"
    key            = "sub-comp-09-pgadmin/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "muoidv-tfstate-lock"
    encrypt        = true
  }
}
