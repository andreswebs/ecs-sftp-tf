data "aws_region" "current" {}

data "aws_ami" "ecs_ami_latest" {
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-ecs-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

locals {
  region     = data.aws_region.current.name
  ecs_ami_id = data.aws_ami.ecs_ami_latest.id

  user_data = base64encode(templatefile("${path.module}/tpl/userdata.tftpl", {
    cluster_name = var.cluster_name
  }))

  instance_sg_ids = [
    aws_security_group.instance.id,
    module.efs.client_security_group.id,
  ]

}

resource "aws_launch_template" "this" {
  name                   = "ecs-${var.cluster_name}"
  description            = "Launch template for ECS cluster ${var.cluster_name}"
  update_default_version = true
  instance_type          = var.instance_type
  image_id               = local.ecs_ami_id
  vpc_security_group_ids = local.instance_sg_ids

  monitoring {
    enabled = true
  }

  iam_instance_profile {
    name = module.ecs_iam.instance_profile.name
  }

  user_data = local.user_data

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ecs-node-${var.cluster_name}"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {

  name = "ecs-${var.cluster_name}"

  vpc_zone_identifier = var.private_subnet_ids

  desired_capacity = var.cluster_desired_capacity
  max_size         = var.cluster_max_size
  min_size         = var.cluster_min_size

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [
      load_balancers,
      target_group_arns,
    ]
  }

}

resource "aws_ecs_capacity_provider" "this" {
  name = var.cluster_name

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.this.arn

    managed_scaling {
      status                    = "DISABLED"
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = [aws_ecs_capacity_provider.this.name]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.log_group_name_prefix}${var.cluster_name}"
  retention_in_days = var.log_retention_in_days
}

locals {
  log_group_name = aws_cloudwatch_log_group.this.name
}

resource "aws_ecs_task_definition" "this" {
  family                   = "wireguard"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = module.ecs_iam.role.execution.arn
  task_role_arn            = module.ecs_iam.role.task.arn
  container_definitions    = jsonencode([local.wg_container_definition])

  volume {
    name = local.wg_conf_name
    efs_volume_configuration {
      file_system_id     = module.efs.file_system.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        iam = "ENABLED"
      }
    }
  }

  volume {
    name      = local.lib_modules_name
    host_path = "/lib/modules"
  }

}

resource "aws_ecs_service" "this" {
  name            = "wireguard"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn

  enable_ecs_managed_tags = true
  enable_execute_command  = true
  force_new_deployment    = var.force_new_deployment
  scheduling_strategy     = "DAEMON"
  launch_type             = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "wireguard"
    container_port   = var.container_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

}
