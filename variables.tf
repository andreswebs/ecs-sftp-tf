variable "cluster_name" {
  type    = string
  default = "sftp"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "cidr_whitelist" {
  type    = list(string)
  default = null
}

variable "sftp_ssm_param_prefix" {
  type    = string
  default = "/sftp"
}

variable "fsx_ssm_param_prefix" {
  type    = string
  default = "/fsx"
}

variable "sftp_users" {
  type = string
}

variable "sftp_main_container_image" {
  type    = string
  default = "atmoz/sftp:latest"
}

variable "sftp_config_container_image" {
  type    = string
  default = "bash:latest"
}
