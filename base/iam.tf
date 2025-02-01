# IAM Role for SSM
resource "aws_iam_role" "ssm_role" {
  name = var.ssm_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach SSM Managed Policy to the Role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = var.ssm_policy_arn

}

# Instance Profile for EC2
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = var.ssm_instance_profile_name
  role = aws_iam_role.ssm_role.name
}

resource "aws_iam_user" "iam_users" {
  for_each = { for user in var.user_details : user.username => user }

  name = each.value.username
  tags = {
    Email = each.value.email
    Role  = each.value.role
  }
}

resource "aws_iam_user_policy_attachment" "iam_user_policy_attachment" {
  for_each = { for pair in var.user_policy_pairs : "${pair.user}-${pair.policy}" => pair }

  user       = aws_iam_user.iam_users[each.value.user].name
  policy_arn = each.value.policy
}

# Generate passwords for IAM users
resource "aws_iam_user_login_profile" "set_password" {
  for_each = aws_iam_user.iam_users

  user                    = each.key
  password_length         = 16
  password_reset_required = false
}

# Store the generated password in Vault
resource "vault_generic_secret" "store_credentials" {
  for_each = aws_iam_user.iam_users

  path = "secret/data/iam_users/${each.key}"

  data_json = jsonencode({
    username = each.key
    email    = each.value.tags.Email
    role     = each.value.tags.Role
    password = aws_iam_user_login_profile.set_password[each.key].password
  })

  depends_on = [aws_iam_user_login_profile.set_password]
}

