# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids
  
  enable_deletion_protection = false
  
  tags = {
    Name        = "${var.project}-${var.environment}-alb"
    Environment = var.environment
    Project     = var.project
    Department  = "IT"
  }
}

# Target Group
resource "aws_lb_target_group" "main" {
  name     = "${var.project}-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  
  tags = {
    Name        = "${var.project}-${var.environment}-tg"
    Environment = var.environment
    Project     = var.project
    Department  = "IT"
  }
}

# Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
  
  tags = {
    Name        = "${var.project}-${var.environment}-http-listener"
    Environment = var.environment
    Project     = var.project
    Department  = "IT"
  }
}
