variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "instance_security_group_id" {
  description = "ID of the security group for the instances"
  type        = string
}

variable "target_group_arns" {
  description = "List of target group ARNs for the ASG"
  type        = list(string)
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project" {
  description = "Project name for resource tagging"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 10
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 2
}

variable "user_data" {
  description = "User data script for the instances"
  type        = string
  default     = ""
}
