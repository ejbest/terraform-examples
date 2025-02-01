terraform {
  backend "s3" {
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_get_ec2_platforms      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = local.ejb_region
  access_key = data.vault_generic_secret.aws_creds.data["access_key"]
  secret_key = data.vault_generic_secret.aws_creds.data["secret_key"]
}

data "vault_generic_secret" "aws_credentials" {
  path = "secret/terraform-aws-secrets"
}

provider "cloudflare" {
  api_token = local.cloudflare_api_token
}

provider "vault" {
  skip_tls_verify = true
  address         = var.vault_address
  token           = var.vault_token
}
