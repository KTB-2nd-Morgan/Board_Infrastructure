#ALB Security Group
resource "aws_security_group" "sg-alb" {
  name   = "alb-sg-morgan-${var.env}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = var.sg_allow_comm_list
    description = ""
    self        = true
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = var.sg_allow_comm_list
    description = ""
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "alb-sg-morgan-${var.env}"
  }
}

#ALB Target Group
resource "aws_lb_target_group" "target-group" {
  name        = "alb-tg-morgan-${var.env}"
  port        = var.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    protocol            = "HTTP"
    path                = var.hc_path                # 예: "/health"
    interval            = var.hc_interval            # 예: 30 (초)
    timeout             = var.hc_timeout             # 예: 5 (초)
    healthy_threshold   = var.hc_healthy_threshold   # 예: 3
    unhealthy_threshold = var.hc_unhealthy_threshold # 예: 3
    matcher             = var.hc_matcher             # 예: "200-399"
  }
  tags = {
    Name = "alb-tg-morgan-${var.env}"
  }
}

resource "aws_lb_target_group_attachment" "target-group-attachment" {
  count            = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.target-group.arn
  target_id        = var.instance_ids[count.index]
  port             = var.port

  availability_zone = var.availability_zone

  depends_on = [aws_lb_target_group.target-group]
}

resource "aws_lb" "alb" {
  name               = "project-dev-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg-alb.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = true

  idle_timeout = var.idle_timeout

  access_logs {
    bucket  = var.aws_s3_lb_logs_name
    prefix  = "alb-${var.env}"
    enabled = true
  }

  tags = {
  Name = "alb-morgan-${var.env}" }
}

# HTTPS Listener (SSL termination)
# resource "aws_lb_listener" "https_listener" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = var.ssl_policy         # 예: "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.certificate_arn    # ACM 인증서 ARN

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.target-group.arn
#   }
# }

# HTTP Listener (리디렉션)
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
  #   default_action {
  #     type = "redirect"
  #     redirect {
  #       port        = "443"
  #       protocol    = "HTTPS"
  #       status_code = "HTTP_301"
  #     }
  #   }
}

resource "aws_lb_listener_rule" "http_listener_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}
