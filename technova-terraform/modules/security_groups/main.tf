# Security group for the ALB
resource "aws_security_group" "alb" {
  name        = "${var.project}-${var.environment}-alb-sg"
  description = "Security group for the application load balancer"
  vpc_id      = var.vpc_id
  
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.project}-${var.environment}-alb-sg"
    Environment = var.environment
    Project     = var.project
    Department  = "IT"
  }
}

# Security group for the EC2 instances
resource "aws_security_group" "instance" {
  name        = "${var.project}-${var.environment}-instance-sg"
  description = "Security group for the web application instances"
  vpc_id      = var.vpc_id
  
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  
  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.project}-${var.environment}-instance-sg"
    Environment = var.environment
    Project     = var.project
    Department  = "IT"
  }
}
