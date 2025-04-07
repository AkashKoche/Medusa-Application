resource "aws_lb" "app" {
  name              = "medusa-alb"
  internal          = false
  load_balance_type = "application"
  security_groups   = [var.alb_sg_id]
  subnets           = var.public_subnets
}


resource "aws_lb_target_group" "backend" {
  name        = "medusa-backend-tg"
  port        = 9000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port = 80
  protocol = "HTTP"


  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "200"
    }
  }
}
