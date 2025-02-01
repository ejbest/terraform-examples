/* 
Creates a role on an AWS Secret Backend for Vault. 
Roles are used to map credentials to the policies that generated them.
 */
resource "vault_aws_secret_backend_role" "role" {
  backend         = var.vault_aws_secret_backend
  name            = "${var.secret_name}-role"
  credential_type = "assumed_role"
  role_arns       = var.role_arns
}

data "vault_aws_access_credentials" "creds" {
  backend = var.vault_aws_secret_backend
  role    = vault_aws_secret_backend_role.role.name
  type    = "sts"
}

resource "vault_generic_secret" "secret" {
  path                = "${var.secret_acc_name}-${var.secret_env}/${var.secret_name}"
  disable_read        = true
  delete_all_versions = true

  data_json = <<EOT
  {
    "access_key": "${data.vault_aws_access_credentials.creds.access_key}",
    "secret_key": "${data.vault_aws_access_credentials.creds.secret_key}",
    "token": "${data.vault_aws_access_credentials.creds.security_token}"
  }

  EOT
}

resource "vault_policy" "ro-secret" {
  name   = "ro-secret-${var.secret_acc_name}-${var.secret_env}/${var.secret_name}"
  policy = <<EOTRO_SECRETPolicy
  path "${var.secret_acc_name}-${var.secret_env}/data/${var.secret_name}" {
    capabilities = ["read", "list"]
  }
  EOTRO_SECRETPolicy
}

