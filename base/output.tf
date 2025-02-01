output "server_private_ip" {
  value = aws_instance.ec2_instance.private_ip
}
output "server_public_dns" {
  value = aws_eip.one.public_dns
}
output "server_public_ip" {
  value = aws_eip.one.public_ip
}
output "server_id" {
  value = aws_instance.ec2_instance.id
}
output "zssh_command" {
  value = "ssh -i base/${var.private_ssh_keyname} ubuntu@${aws_eip.one.public_dns}"
}
output "zbrowser" {
  value = "https://${var.domain_name}"
}

output "iam_user_details" {
  value = {
    for user, details in aws_iam_user.iam_users : user => {
      email = details.tags["Email"]
      role  = details.tags["Role"]
    }
  }
}

