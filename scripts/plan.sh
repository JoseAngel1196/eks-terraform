#!/bin/bash

WORKSPACE=$1

# Use a loop to execute `terragrunt` commands on each matchin directory.
find ./ -name "terragrunt.hcl" | while read dir; do
    cd "$(dirname "$dir")" && terragrunt init -no-color --terragrunt-tfpath terraform &&
        if ! terragrunt workspace select $WORKSPACE -no-color --terragrunt-tfpath terraform; then
            terragrunt workspace new $WORKSPACE -no-color --terragrunt-tfpath terraform
        fi
done

terragrunt run-all plan --terragrunt-non-interactive -var-file=vars/$WORKSPACE.tfvars --terragrunt-tfpath terraform
