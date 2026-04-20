provider "aws" {
  region = var.aws_region
}

# ------------------------------------------------------------------------------
# TERRAFORM STATE BACKEND 
# Recommendation for Idempotency: 
# Since GitHub runners are ephemeral, Terraform loses its state file on every run.
# To make this fully idempotent across multiple GitHub Action runs, you MUST
# create an S3 bucket in AWS first, then uncomment and update the block below:
# ------------------------------------------------------------------------------
# terraform {
#   backend "s3" {
#     bucket         = "YOUR-UNIQUE-S3-BUCKET-NAME"
#     key            = "shopsmart/terraform.tfstate"
#     region         = "us-east-1"
#     # dynamodb_table = "terraform-state-lock" # Optional but recommended
#     encrypt        = true
#   }
# }


# ------------------------------------------------------------------------------
# ECR REPOSITORY
# ------------------------------------------------------------------------------
resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.project_name}-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ------------------------------------------------------------------------------
# ECS CLUSTER
# ------------------------------------------------------------------------------
resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.project_name}-cluster"
}

# ------------------------------------------------------------------------------
# IAM ROLES
# ------------------------------------------------------------------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 30
}

# ------------------------------------------------------------------------------
# ECS TASK DEFINITION
# ------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  # We use the ECR repository URL, but with a 'latest' tag. 
  # For the very first terraform apply, if the image isn't pushed to ECR yet, 
  # ECS will fail to pull the image and the tasks will fail to start.
  # The GitHub pipeline will build the image, push it to ECR, and update the service.
  # To avoid the initial terraform apply failure, we can use a dummy image like nginx 
  # OR we can assume GitHub actions pushes the image before updating the service.
  # For pure automation, it's common to use a public placeholder image initially.
  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-container"
      image     = "${aws_ecr_repository.app_repo.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# ------------------------------------------------------------------------------
# NETWORKING (Using Default VPC for simplicity)
# ------------------------------------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.project_name}-ecs-sg"
  description = "Allow inbound traffic on app port"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------------------------------------------------------
# ECS SERVICE
# ------------------------------------------------------------------------------
resource "aws_ecs_service" "app_service" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
