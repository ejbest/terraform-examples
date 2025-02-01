module "aws-ej-engine" {
  source                   = "./base/aws-vault/secret-engine"
  path                     = "aws"
  description              = "Manage Iam users using vault in AWS"
  access_key               = local.access_key
  secret_key               = local.secret_key
  vault_aws_secret_backend = "aws-ej"
}

module "username3" {
  source                   = "./base/aws-vault/roles"
  secret_name              = "username3"
  role_arns                = ["arn:aws:iam::891377215370:role/administrator-access-role"]
  secret_env               = "prod"
  secret_acc_name          = "ej"
  access_key               = local.access_key
  secret_key               = local.secret_key
  vault_aws_secret_backend = module.aws-ej-engine.vault_aws_secret_backend_path
}

module "username2" {
  source                   = "./base/aws-vault/roles"
  secret_name              = "username2"
  role_arns                = ["arn:aws:iam::891377215370:role/administrator-access-role"]
  secret_env               = "prod"
  secret_acc_name          = "ej"
  access_key               = local.access_key
  secret_key               = local.secret_key
  vault_aws_secret_backend = module.aws-ej-engine.vault_aws_secret_backend_path
}
