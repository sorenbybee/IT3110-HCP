terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.45.0"
    }
  }
}

provider "aws" {
  region                   = var.aws_region
  shared_credentials_files = ["~/.aws/credentials"]
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  environment          = var.environment
  project              = var.project
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security_groups"
  
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  project     = var.project
}

# Load Balancer Module
module "alb" {
  source = "./modules/alb"
  
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_sg_id
  environment       = var.environment
  project           = var.project
}

# Auto Scaling Group Module
module "asg" {
  source = "./modules/asg"
  
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  instance_security_group_id = module.security_groups.instance_sg_id
  target_group_arns     = [module.alb.target_group_arn]
  environment           = var.environment
  project               = var.project
  instance_type         = var.instance_type
  min_size              = var.min_instance_count
  max_size              = var.max_instance_count
  desired_capacity      = var.desired_instance_count
  user_data             = file("${path.module}/scripts/user_data.sh")
}

# Outputs
output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.alb.alb_dns_name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}
