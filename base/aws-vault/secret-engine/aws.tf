resource "vault_auth_backend" "aws" {
  type = "aws"
  path = var.path
}

resource "vault_aws_auth_backend_client" "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  backend    = vault_auth_backend.aws.path
}

/* 
Creates an AWS Secret Backend for Vault. 
AWS secret backends can then issue AWS access keys and secret keys, 
once a role has been added to the backend.
 */
resource "vault_aws_secret_backend" "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  path       = var.vault_aws_secret_backend
}
