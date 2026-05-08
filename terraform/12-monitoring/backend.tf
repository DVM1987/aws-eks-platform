terraform {
  backend "s3" {
    bucket         = "muoidv-tfstate-527055790396"
    key            = "sub-comp-12-monitoring/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "muoidv-tfstate-lock"
    encrypt        = true
  }
}
