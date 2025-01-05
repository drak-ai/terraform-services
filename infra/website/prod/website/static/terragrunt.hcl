terraform {
  source = "../../../../../modules/shared/website/static"
}

include {
  path = "../../../terragrunt.hcl"
}

inputs = {}
