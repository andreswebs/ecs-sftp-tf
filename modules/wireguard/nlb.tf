resource "aws_lb" "this" {
  name               = var.cluster_name
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.lb.id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "this" {
  name        = var.cluster_name
  vpc_id      = var.vpc_id
  protocol    = "UDP"
  target_type = "instance"
  port        = var.container_port

  health_check {
    protocol = var.health_check_protocol
    port     = var.health_check_port
    path     = var.health_check_path
  }

}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.container_port
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
