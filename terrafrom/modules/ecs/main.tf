resource "aws_ecs_cluster" "main" {
  name = var.name
}


resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-task-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })


  tags = {
    Name = "${var.name}-task-exec-role"
  }
}


resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role        = aws_iam_role.ecs_task_execution_role.name
  policy_arn  = "arn:aws:iam:aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_task_definition" "backend" {
  family               = "medusa-store"
  network              = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn


  container_definition = jsonencode([
    {
      name            = "medusa-store"
      image           = var.backend_image
      essential       = true
      portMappings    = [{
        containerPort = 9000,
        hostPort      = 9000
      }],
      environment = [
        {
          name = "DATABASE_URL"
          value = var.db_url
        }
      ]
    }
  ])
}


resource "aws_ecs_task_definition" "frontend" {
  family               = "medusa-store-front"
  network_mode         = "awsvpc"
  require_compatibilities = ["FARGATE"]
  cpu                     = 512
  memory                  = 1024
  execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn


  container_definitions = jsonencode([
    {
      name            = "medusa-store-front"
      image           = var.frontend_image
      essential       = true
      portMappings    = [{
        containerPort = 3000,
        hostPort      = 3000
      }]
    }
  ])
}


resource "aws_security_group" "ecs_sg" {
  name        = "${var.name}-ecs-sg"
  description = "Allow HTTP"
  vpc_id      = var.vpc_id


  ingress {
    from_port    = 3000
    to_port      = 3000
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  ingress {
    from_port  = 9000
    to_port    = 9000
    protocol   = "tcp"
    cidr_block = ["0.0.0.0/0"]
  }

  egress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-ecs-sg"
  }
}


resource "aws_ecs_service" "backend" {
  name = "medusa-store"
  cluster = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count = 1
  launch_type = "FARGATE"


  network_configuration {
    subnets     = var.public_subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}


resource "aws_ecs_service" "frontend" {
  name            = "medusa-store-front"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch          = "FARGATE"


  network_configuration {
    subnets          = var.public_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
