resource "aws_ebs_volume" "data_volume" {
  availability_zone = var.availability_zone
  size              = var.ebs_volume_size
  tags = {
    Name = var.ebs_tags
  }
}

resource "aws_volume_attachment" "attach_data_volume" {
  device_name = var.ebs_volume_device_name
  volume_id   = aws_ebs_volume.data_volume.id
  instance_id = aws_instance.ec2_instance.id
}



