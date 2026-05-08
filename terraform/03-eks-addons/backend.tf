terraform {
  backend "s3" {
    bucket         = "muoidv-tfstate-527055790396"
    key            = "sub-comp-03-eks-addons/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "muoidv-tfstate-lock"
  }
}
