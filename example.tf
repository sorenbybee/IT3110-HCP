terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.91.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0b4bf1a9cf54c11d0"
  instance_type = "t2.micro"
}

variable "AWS_ACCESS_KEY_ID" {
  type        = string
  description = "Your AWS Access Key ID"
}

variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
  description = "Your AWS Secret access key"
}

variable "AWS_SESSION_TOKEN" {
  type        = string
  description = "Your AWS Session token"
}