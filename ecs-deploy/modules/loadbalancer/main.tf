####################################################
// --------- Application Load Balancer ---------- //
####################################################

resource "aws_lb" "lb" {
  name               = "${var.infra_role}-load-balancer-${var.infra_env}"
  load_balancer_type = "application"
  internal           = false
  // subnets in 2 different AZ
  subnets         = var.subnet_public_ids
  security_groups = [var.sg_alb]
}

####################################################
// --------- load balance target group ---------- //
####################################################

resource "aws_lb_target_group" "tg" {
  name        = "${var.infra_role}-target-group-${var.infra_env}"
  port        = var.dagit_container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200,301,302"
  }
}


####################################################
// ------------ load balance listener ----------- //
####################################################

resource "aws_lb_listener" "lb" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80 // List on port 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}