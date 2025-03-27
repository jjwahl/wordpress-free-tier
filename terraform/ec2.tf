resource "aws_instance" "ec2" {
  ami           = "ami-002d7d8815f3d2baa"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.wordpress_sg.name]

  tags = {
    Name = "WordPressServer"
  }
}
