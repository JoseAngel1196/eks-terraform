terraform {
  required_version = "1.4.2"
}

provider "aws" {
  region     = "us-east-1"
  profile = "cloud_user"
}

module "vpc" {
  source = "../../modules/vpc"

  name             = var.name
  cidr_block       = var.cidr_block
  max_subnets      = var.max_subnets
  private_sn_count = var.private_sn_count
  public_sn_count  = var.public_sn_count
  public_cidrs     = var.public_cidrs
  private_cidrs    = var.private_cidrs
}
