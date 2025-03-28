provider "aws" {
  region = "us-east-1"
}


data "aws_vpc" "default" {
  default = true
}

resource "aws_db_instance" "wordpress_db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.35"
  instance_class       = "db.t3.micro"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  username             = "admin"
  password             = var.db_password
  storage_type         = "gp2"
  publicly_accessible  = false
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
