provider "aws" {
  region = "us-east-1"
}


resource "aws_vpc" "wp_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "wordpress-free-tier" }
}

resource "aws_db_instance" "wordpress_db" {
  allocated_storage = 20
  engine  = "mysql"
  engine_version = "5.7.42"
  instance_class = "db.t2.micro"
  username = "admin"
  password = var.db_password
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot = true
}



resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name          = "wordpress-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EC2 CPU > 80%"
  dimensions = {
    InstanceId = aws_instance.wordpress.id
  }
}




variable "db_password" {
  sensitive = true
}
