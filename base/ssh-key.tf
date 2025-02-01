resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.ec2_ssh_key_pair_name
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "pem_file" {
  filename        = "${path.module}/${var.private_ssh_keyname}"
  file_permission = "400"
  content         = tls_private_key.ssh_key.private_key_pem
}

