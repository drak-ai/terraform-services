terraform {
  backend "s3" {}
  required_version = ">= 1.5.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

locals {
  tags = {
    App         = var.app
    Environment = var.env
    Product     = var.product
  }
}

data "aws_caller_identity" "current" {}

provider "aws" {
  region  = var.region
  profile = var.profile
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "aws" {
  region  = "us-east-1"
  profile = var.profile
  alias   = "global"
}

data "terraform_remote_state" "dns" {
  backend = "s3"
  config = {
    bucket  = var.remote_state_bucket
    key     = "base/dns/${var.domain}/terraform.tfstate"
    region  = "eu-west-1"
    profile = "drak"
  }
}

module "acm" {
  source         = "git::ssh://git@github.com/drak-ai/terraform-modules.git//modules/aws/acm?ref=main"
  zone_validator = "cloudflare"
  domain         = var.domain
  tags           = var.tags

  providers = {
    aws = aws.global
  }
}

module "s3" {
  source = "git::ssh://git@github.com/drak-ai/terraform-modules.git//modules/aws/s3-static-website?ref=main"
  domain = var.domain
  tags   = local.tags
}

module "cloudfront" {
  source           = "git::ssh://git@github.com/drak-ai/terraform-modules.git//modules/aws/cloudfront?ref=main"
  app              = var.app
  env              = var.env
  product          = var.product
  domain           = var.domain
  acm_arn          = module.acm.acm_arn
  website_endpoint = module.s3.website_endpoint
  tags             = local.tags

  providers = {
    aws = aws.global
  }
}

resource "cloudflare_record" "app" {
  zone_id         = data.terraform_remote_state.dns.outputs.cloudflare_zone.id
  name            = var.domain
  value           = module.cloudfront.cf_domain_name
  allow_overwrite = false
  proxied         = false
  type            = "CNAME"
  ttl             = 1
}
