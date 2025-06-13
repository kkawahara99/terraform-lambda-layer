terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {
    bucket = "tfstate-bucket-name"
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = var.aws_region
}

module "lambda" {
  source    = "../modules/lambda"
  stage     = var.stage
  func_name = "account_issue"
  env_vars  = { STAGE = var.stage }
}
