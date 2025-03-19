# Latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Launch template
resource "aws_launch_template" "main" {
  name_prefix   = "${var.project}-${var.environment}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.instance_security_group_id]
  }
  
  user_data = base64encode(var.user_data)
  
  tag_specifications {
    resource_type = "instance"
    
    tags = {
      Name        = "${var.project}-${var.environment}-instance"
      Environment = var.environment
      Project     = var.project
      Department  = "IT"
    }
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                = "${var.project}-${var.environment}-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = var.target_group_arns
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
  
  health_check_type         = "ELB"
  health_check_grace_period = 300
  
  tag {
    key                 = "Name"
    value               = "${var.project}-${var.environment}-asg-instance"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Department"
    value               = "IT"
    propagate_at_launch = true
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Scale up policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project}-${var.environment}-scale-up"
  autoscaling_group_name = aws_autoscaling_group.main.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

# Scale down policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project}-${var.environment}-scale-down"
  autoscaling_group_name = aws_autoscaling_group.main.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

# CloudWatch alarm for high CPU utilization
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project}-${var.environment}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
  
  alarm_description = "Scale up if CPU utilization is above 70% for 4 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
  
  tags = {
    Name        = "${var.project}-${var.environment}-high-cpu-alarm"
    Environment = var.environment
    Project     = var.project
    Department  = "IT"
  }
}

# CloudWatch alarm for low CPU utilization
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.project}-${var.environment}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
  
  alarm_description = "Scale down if CPU utilization is below 30% for 4 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
  
  tags = {
    Name        = "${var.project}-${var.environment}-low-cpu-alarm"
    Environment = var.environment
    Project     = var.project
    Department  = "IT"
  }
}