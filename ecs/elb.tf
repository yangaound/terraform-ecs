resource "aws_lb" "elb" {
  name            = "ALB"
  internal        = false
  security_groups = [aws_security_group.elb_security_group.id]
  subnets         = data.terraform_remote_state.vpc.outputs.public-subnets

  tags = {
    Name = "ALB"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.elb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.elb_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_default_target_group.arn
  }

  depends_on = [aws_lb_target_group.ecs_default_target_group]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "ecs_default_target_group" {
  name     = "ELB-DFL-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc-id

  tags = {
    Name = "ELB-DFL-TG"
  }
}

resource "aws_route53_record" "ecs_load_balancer_record" {
  name = "*.${var.hosted_zone_name}"
  type = "A"
  zone_id = data.aws_route53_zone.hosted_zone.zone_id

  alias {
    evaluate_target_health  = false
    name                    = aws_lb.elb.dns_name
    zone_id                 = aws_lb.elb.zone_id
  }
}
