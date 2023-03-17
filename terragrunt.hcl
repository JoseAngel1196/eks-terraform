remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    region               = "us-east-1"
    bucket               = "private-eks-terraform-state"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
    encrypt              = true
    profile              = "cloud_user"
  }
}
