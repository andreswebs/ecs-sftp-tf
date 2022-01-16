module "ssh" {
  source             = "andreswebs/insecure-ec2-key-pair/aws"
  version            = "1.0.0"
  key_name           = "ecs-sftp"
  ssm_parameter_name = "/ecs/sftp/ssh-key"
}

module "sftp" {
  source                      = "andreswebs/ecs-fsx-sftp/aws"
  version                     = "0.0.2"
  cluster_name                = var.cluster_name
  vpc_id                      = var.vpc_id
  subnet_ids                  = var.subnet_ids
  cidr_whitelist              = var.cidr_whitelist
  fsx_ssm_param_prefix        = var.fsx_ssm_param_prefix
  sftp_ssm_param_prefix       = var.sftp_ssm_param_prefix
  sftp_users                  = var.sftp_users
  sftp_main_container_image   = var.sftp_main_container_image
  sftp_config_container_image = var.sftp_config_container_image
  ssh_key_name                = module.ssh.key_pair.key_name
}
