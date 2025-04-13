resource "aws_key_pair" "wp_key" {
  key_name = "wordpress-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0CgkEeR0Y9pd10Bj8EuCJgrLspN6WyaP0PYhMha9eHpCJuLuAm6bKU9KGKOLBMPCIbBubIYxALx6FVfPJB9AWNB3AW1QkzWMOwrw7SwDbzMabEBASG673Xt3a9j6gWfxt7xSX7Q/VvwsYRmgixcKzqoh6Mo5wYawWUhwEXYvXm8unAtlob4dmPVNjD3XRpUq8J8/irfYDN6HGTdcCTPsfksSAavuEUe0NREgwgB0xjbtTWuNvLaN5gbwo6a+lFLbzN/pBMj43xWANX/HisTwFztl/zEJXYy9HJi6maGCmRBnADUcr3B65O+bWgS8fHfDX8aDSj6Tnd9zArnDjL0uojxq7+u21hmPytg64I1g17Uktsk9Cs7wwA54NDkAfiQsVd12i1/duBwRa9hF9W65u/zTzSvHGrIOQfFh/MedTym1TuzHbzAClBCqKtAILvZvyKs0qyZDAlmcrEZb1/yCgQXbJrJt4Y/1J27PC3iX2bZA9EaXAz1aC8WKM0QPlYf7EI+qQWGyLweebeHegSMBvR7aPLg6s2oQgUTjSEXQn3DZpCd3zfsrQSCI7/issVlo0t1qm9AqIe+f6ce4s1Bbu8jGg7UxKCN7DE7cBrcL/rBa1WYn2DPktKCWCskeUI4VJDYK4mBuCPULV2D87r9a7DONLrXZT3v4ThAr5Gm1HNw== jjwahl@DESKTOP-CASA"
}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


resource "aws_instance" "wordpress" {
  depends_on = [aws_db_instance.wordpress_db]
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  key_name = aws_key_pair.wp_key.key_name
  user_data = file("user_data.sh")
  associate_public_ip_address = true
  subnet_id     = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.web.id]
  tags = {
    Name = "wordpress-free-tier"
  }
  user_data = templatefile("user-data.sh", {
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
    db_endpoint = aws_db_instance.wordpress_db.endpoint
  })
}
