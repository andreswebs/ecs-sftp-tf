variable "cluster_name" {
  type        = string
  description = "ECS cluster name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs"
  validation {
    condition     = length(var.private_subnet_ids) > 0
    error_message = "Must contain at least one."
  }
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs"
  validation {
    condition     = length(var.public_subnet_ids) > 0
    error_message = "Must contain at least one."
  }
}

variable "cluster_desired_capacity" {
  type        = number
  default     = 1
  description = "ECS cluster ASG desired capacity"
}

variable "cluster_max_size" {
  type        = number
  default     = 3
  description = "ECS cluster ASG maximum instance count"
}

variable "cluster_min_size" {
  type        = number
  default     = 1
  description = "ECS cluster ASG minimum instance count"
}

variable "instance_type" {
  type        = string
  default     = "t3a.small"
  description = "ECS container-instance type"
}

variable "log_retention_in_days" {
  type        = number
  default     = 30
  description = "CloudWatch Logs retention in days"
}

# variable "instance_profile_name" {
#   type        = string
#   description = "ECS container-instance IAM profile name"
# }

# variable "container_port" {
#   type        = number
#   description = "The app container exposed port"
#   default     = 8080
# }

variable "health_check_path" {
  type        = string
  description = "The health check path"
  default     = "/health"
}

variable "certificate_arn" {
  type        = string
  description = "The ARN of the SSL certificate"
  default     = null
}
