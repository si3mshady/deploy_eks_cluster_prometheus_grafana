
locals {
 aws_region = "us-west-2"
}

provider "aws" {
  region = local.aws_region

}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    
    }
  }
}

