terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    arguments = [
      "-input=false",
    ]
  }
  extra_arguments "init_args" {
    commands = [
      "init",
    ]

    arguments = [
      "-backend-config=key=kohorty/${path_relative_to_include()}/terraform.tfstate",
      "-backend-config=${get_terragrunt_dir()}/../../backend.tfvars",
    ]
  }
}

inputs = merge(
  yamldecode(file("${get_terragrunt_dir()}/../../environment_vars.yaml")),
  yamldecode(file("${get_terragrunt_dir()}/../service_vars.yaml")),
  {
    product               = "drak-ai"
    owner                 = "sergey.pokatov"
    region                = "eu-west-1"
    state_s3_path_service = "${dirname(path_relative_to_include())}"
  }
)
