resource "aws_instance" "app" {
  ami           = var.ami
  instance_type = var.instance_type

  subnet_id = aws_subnet.public_subnet_1.id

  vpc_security_group_ids = [
    aws_security_group.app_sg.id
  ]

  user_data = file("userdata.sh")

  tags = {
    Name = "devops-app"
  }
}

resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app_tg.arn

  target_id = aws_instance.app.id

  port = 3000
}