locals {
  ecs_instance_name = "ecs-sftp-instance"
}

module "iam_ecs_instance" {
  source       = "andreswebs/ec2-role/aws"
  version      = "1.0.0"
  role_name    = local.ecs_instance_name
  profile_name = local.ecs_instance_name
  policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  ]
}

module "ssh" {
  source             = "andreswebs/insecure-ec2-key-pair/aws"
  version            = "1.0.0"
  key_name           = "ecs-sftp"
  ssm_parameter_name = "/andre/ecs/sftp/ssh-key"
}

module "sftp" {
  source                      = "andreswebs/ecs-fsx-sftp/aws"
  version                     = "0.0.1"
  cluster_name                = var.cluster_name
  vpc_id                      = var.vpc_id
  subnet_ids                  = var.subnet_ids
  ami_id                      = var.ami_id
  cidr_whitelist              = var.cidr_whitelist
  sftp_ssm_param_prefix       = var.sftp_ssm_param_prefix
  sftp_users                  = var.sftp_users
  sftp_main_container_image   = var.sftp_main_container_image
  sftp_config_container_image = var.sftp_config_container_image
  instance_profile            = module.iam_ecs_instance.instance_profile.name
  ssh_key_name                = module.ssh.key_pair.key_name
}
