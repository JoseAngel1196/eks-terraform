#!/bin/bash

WORKSPACE=$1

find ./ -name "terragrunt.hcl" | while read dir; do
    cd "$(dirname "$dir")" && terragrunt init -no-color --terragrunt-tfpath terraform &&
        if ! terragrunt workspace select $WORKSPACE -no-color --terragrunt-tfpath terraform; then
            terragrunt workspace new $WORKSPACE -no-color --terragrunt-tfpath terraform
        fi
done

terragrunt apply-all --terragrunt-non-interactive -auto-approve -no-color -var-file=vars/$WORKSPACE.tfvars --terragrunt-tfpath terraform
