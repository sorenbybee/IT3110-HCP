# TechNova AWS Infrastructure

This Terraform project creates a scalable, secure, and highly available AWS infrastructure for TechNova's web application.

## Infrastructure Components

- VPC with public and private subnets across multiple availability zones
- Application Load Balancer in public subnets
- Auto Scaling Group with instances in private subnets
- Security groups for controlled access
- CloudWatch alarms for auto-scaling

## Getting Started

1. Ensure you have AWS credentials configured in `~/.aws/credentials`
2. Initialize the Terraform project:
   ```
   terraform init
   ```
3. Create an execution plan:
   ```
   terraform plan
   ```
4. Apply the configuration:
   ```
   terraform apply
   ```

## Architecture

The infrastructure follows AWS best practices:
- Multi-AZ deployment for high availability
- Private subnets for application instances
- Load balancing across instances
- Auto scaling based on demand

## Outputs

After successful deployment, you'll receive:
- ALB DNS name for accessing the application
- VPC and subnet IDs for reference

## Clean Up

To destroy all resources created by this project:
```
terraform destroy
```
