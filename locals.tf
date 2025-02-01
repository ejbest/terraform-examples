locals {
  # vpc
  ejb_environment           = data.vault_generic_secret.aws_vars.data["ejb_environment"]
  ejb_region                = data.vault_generic_secret.aws_vars.data["ejb_region"]
  ejb_availability_zone     = data.vault_generic_secret.aws_vars.data["ejb_availability_zone"]
  ejb_instance_type         = data.vault_generic_secret.aws_vars.data["ejb_instance_type"]
  ejb_cidr_block            = data.vault_generic_secret.aws_vars.data["ejb_cidr_block"]
  ejb_ipv6_cidr_block       = data.vault_generic_secret.aws_vars.data["ejb_ipv6_cidr_block"]
  ejb_ami_id                = data.vault_generic_secret.aws_vars.data["ejb_ami_id"]
  ejb_key_name              = data.vault_generic_secret.aws_vars.data["ejb_key_name"]
  ssm_role_name             = "ejb-ssm-role"
  ssm_instance_profile_name = "ejb-ssm-instance-profile"
  ssm_policy_arn            = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  vpc_tags                  = "ejb_production_vpc"

  # aws
  access_key = data.vault_generic_secret.aws_credentials.data["access_key"]
  secret_key = data.vault_generic_secret.aws_credentials.data["secret_key"]

  # subnet
  ejb_sub1_cidr_block   = data.vault_generic_secret.aws_vars.data["ejb_sub1_cidr_block"]
  route_cidr_block      = data.vault_generic_secret.aws_vars.data["route_cidr_block"]
  web_server_private_ip = data.vault_generic_secret.aws_vars.data["web_server_private_ip"]

  # security group
  ejb_rt_name            = data.vault_generic_secret.aws_vars.data["ejb_rt_name"]
  ejb_subnet_name        = data.vault_generic_secret.aws_vars.data["ejb_subnet_name"]
  ejb_sg_name            = data.vault_generic_secret.aws_vars.data["ejb_sg_name"]
  sg_protocol            = data.vault_generic_secret.aws_vars.data["sg_protocol"]
  sg_ingress_cidr_blocks = data.vault_generic_secret.aws_vars.data["sg_ingress_cidr_blocks"]
  sg_egress_protocol     = data.vault_generic_secret.aws_vars.data["sg_egress_protocol"]
  sg_egress_cidr_blocks  = data.vault_generic_secret.aws_vars.data["sg_egress_cidr_blocks"]
  ejb_sg_tags_name       = data.vault_generic_secret.aws_vars.data["ejb_sg_tags_name"]
  aws_eip_domain         = data.vault_generic_secret.aws_vars.data["aws_eip_domain"]

  # EBS
  ejb_ebs_volume_device_name = "/dev/xvdf"
  ejb_ebs_volume_size        = 10
  ejb_ebs_tags               = "ejb-data-volume"

  # SSH key
  ssh_key_algorithm   = data.vault_generic_secret.aws_vars.data["ssh_key_algorithm"]
  ssh_key_rsa_bits    = data.vault_generic_secret.aws_vars.data["ssh_key_rsa_bits"]
  ejb_private_keyname = "test-key.pem"

  # web server
  ejb_webserver_name = data.vault_generic_secret.aws_vars.data["ejb_webserver_name"]
  #domain_name        = "deployment.auto-deploy.net"

  # Cloudflare
  cloudflare_api_email = data.vault_generic_secret.cloudflare_api_tokens.data["cloudflare_auto_deploy_email"]
  cloudflare_api_token = data.vault_generic_secret.cloudflare_api_tokens.data["cloudflare_auto_deploy_token"]
  cloudflare_zone      = data.vault_generic_secret.cloudflare_zone_vars.data["auto_deploy_zone"]

  # vault
  #vault_address = "https://vault.waterskiingguy.com"

  # Iam 
  user_details = nonsensitive(jsondecode(data.vault_generic_secret.all_user_details.data["users"]))
  role_policies = {
    "Admin-Role" = [
      "arn:aws:iam::aws:policy/AdministratorAccess"
    ]
    "EC2-Role" = [
      "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    ]
    "S3-Role" = [
      "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    ]
  }
  user_policy_pairs = flatten([
    for user in local.user_details : [
      for policy in local.role_policies[user.role] : {
        user   = user.username
        policy = policy
      }
    ]
  ])

  # common tags
  common_tags = {
    environment = local.ejb_environment
    team        = data.vault_generic_secret.aws_vars.data["team"]
    project     = data.vault_generic_secret.aws_vars.data["project"]
  }
  sg_description = "Allow web inbound traffic and all outbound traffic"
  security_group_ingress_rules = [
    {
      description = "HTTPS traffic"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = local.sg_ingress_cidr_blocks
    },
    {
      description = "HTTP traffic"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = local.sg_ingress_cidr_blocks
    },
    {
      description = "SSH traffic"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = local.sg_ingress_cidr_blocks
    },
  ]

  dns_records = {
    db-root = {
      name     = "deployment"
      content  = module.webserver.server_public_ip
      type     = "A"
      ttl      = 3600
      priority = 0
    }
  }
}

