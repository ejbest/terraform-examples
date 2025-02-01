# Create Internet Gateway 
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

# Create Route Table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.rt_ipv4_cidr_block
    gateway_id = aws_internet_gateway.gw.id

  }

  route {
    ipv6_cidr_block = var.rt_ipv6_cidr_block
    gateway_id      = aws_internet_gateway.gw.id

  }
  tags = {
    Name = var.rt_name
  }
}

# Create a subnet
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = var.subnet_tags
  }
}

# Associate subnet with route table 
resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

# Create Security group
resource "aws_security_group" "sg" {
  name        = var.sg_name
  vpc_id      = aws_vpc.vpc.id
  description = var.sg_description

  dynamic "ingress" {
    for_each = var.sg_ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = [ingress.value.cidr_blocks]
    }
  }

  # Outbound traffic for all ports and protocols
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg_tags_name
  }
}

# Create network interface 
resource "aws_network_interface" "nic" {
  subnet_id       = aws_subnet.subnet.id
  private_ips     = [var.web_server_private_ip]
  security_groups = [aws_security_group.sg.id]
}

# Assign Public EIP
resource "aws_eip" "one" {
  domain                    = var.aws_eip_domain
  network_interface         = aws_network_interface.nic.id
  associate_with_private_ip = var.web_server_private_ip
  depends_on                = [aws_internet_gateway.gw, aws_instance.ec2_instance]
}

resource "aws_eip_association" "ec2_eip_association" {
  instance_id   = aws_instance.ec2_instance.id
  allocation_id = aws_eip.one.id
}
