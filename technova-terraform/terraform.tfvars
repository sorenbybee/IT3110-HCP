aws_region = "us-west-2"
environment = "prod"
project = "technova"

vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

instance_type = "t2.micro"
min_instance_count = 2
max_instance_count = 10
desired_instance_count = 2
