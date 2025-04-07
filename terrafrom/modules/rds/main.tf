resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.db_name}-subnet-group"
  subnet_ids = var.private_subnets


  tags = {
    Name = "${var.db_name}-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier             = var.db_name
  engine                 = "postgres"
  engine_version         = "15.3"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  name                   = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false


  tags = {
    Name = var.db_name
  }
}


resource "aws_security_group" "rds_sg" {
  name        = "${var.db_name}-sg"
  description = "Allow Postgres access"
  vpc_id      = var.vpc_id


  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }


  engress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "${var.db_name}-sg"
  }
}


output "db_instance_endpoint" {
  value = aws_db_instance.postgres.endpoint
}
