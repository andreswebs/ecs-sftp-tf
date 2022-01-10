variable "cluster_name" {
  type    = string
  default = "default"
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
  type = string
}

variable "ami_id" {
  type = string
}

variable "sftp_users" {
  type = string
}

variable "sftp_main_container_image" {
  type        = string
  default     = "atmoz/sftp:latest"
}

variable "sftp_config_container_image" {
  type        = string
  default     = "bash:latest"
}
