data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    tier = "private"
  }
}

resource "aws_lb" "ecs_alb" {
  name               = "ecs-ingress"
  load_balancer_type = "application"
  internal           = true
  security_groups    = [aws_security_group.default.id]
  subnets            = [for s in data.aws_subnets.private.ids : s]
}

resource "aws_lb_listener" "ecs-ingress-http" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs-ingress.arn
  }
}

resource "aws_lb_listener" "ecs-ingress-https" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-2:account-id:certificate/cbdb09e1-342d-4e6c-8008-ebc02dfe4001"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs-ingress.arn
  }
}

resource "aws_lb_target_group" "ecs-proxy" {
  name     = "ecs-proxy"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}
