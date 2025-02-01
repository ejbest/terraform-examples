# EC2 Webserver creation
resource "aws_instance" "ec2_instance" {
  ami                  = var.ami_id
  instance_type        = var.instance_type
  availability_zone    = var.availability_zone
  key_name             = aws_key_pair.generated_key.key_name
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.nic.id
  }

  user_data = templatefile("${path.module}/scripts/cloud_init.sh", {
    SSH_PUBLIC_KEY = tls_private_key.ssh_key.public_key_openssh

  })

  tags = {
    Name = var.ec2_tags
  }

}

data "template_file" "setup_script" {
  template = file("${path.module}/scripts/setup.sh")

  vars = {
    DOMAIN_NAME = var.domain_name
  }
}


resource "null_resource" "install_packages" {
  connection {
    type        = "ssh"
    host        = aws_eip.one.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.ssh_key.private_key_pem
    agent       = false
    timeout     = "2m"
  }

  provisioner "file" {
    content     = data.template_file.setup_script.rendered
    destination = "/tmp/setup.sh"
  }
  provisioner "file" {
    source      = "${path.module}/scripts/progress_checker.sh"
    destination = "/tmp/progress_checker.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/progress_checker.sh",
      "chmod +x /tmp/setup.sh",
      "/tmp/progress_checker.sh",
      "/tmp/setup.sh"
    ]
  }

}

