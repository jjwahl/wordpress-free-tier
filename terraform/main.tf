provider "aws" {
  region = "us-east-1"
}

resource "aws_db_subnet_group" "default" {
  name       = "wordpress-subnet-group"
  subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  tags = {
    Name = "WordPress DB Subnet Group"
  }
}


resource "aws_db_instance" "wordpress_db" {
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name = aws_db_subnet_group.default.name
  allocated_storage  = 20
  engine = "mysql"
  engine_version = "8.0.35"
  instance_class = "db.t3.micro"
  db_name              = var.db_name
  username             = var.db_user
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot = true
  storage_type = "gp2"
  publicly_accessible = false
}

resource "aws_security_group" "web" {
  name        = "wordpress-web"
  description = "Allow HTTP/SSH traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_security_group" "rds" {
  name        = "wordpress-rds"
  description = "Allow MySQL from EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]  # for EC2!
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name = "wordpress-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 300
  statistic = "Average"
  threshold = 80
  alarm_description = "EC2 CPU > 80%"
  dimensions = {
    InstanceId = aws_instance.wordpress.id
  }
}




variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "WordPress database name"
  type        = string
  default     = "wordpress_db"
}

variable "db_user" {
  description = "WordPress database user"
  type        = string
  default     = "admin"
}
