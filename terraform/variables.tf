variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "shopsmart-v2"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
  default     = "prod"
}

variable "app_port" {
  description = "Port exposed by the docker image"
  type        = number
  default     = 5001
}
