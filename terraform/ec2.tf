resource "aws_instance" "app" {
  ami           = var.ami
  instance_type = var.instance_type

  subnet_id = aws_subnet.public_subnet_1.id

  vpc_security_group_ids = [
    aws_security_group.app_sg.id
  ]

  iam_instance_profile = aws_iam_instance_profile.app.name

  user_data = templatefile("${path.module}/userdata.sh", {
    db_secret_arn = aws_db_instance.postgres.master_user_secret[0].secret_arn
    db_host       = aws_db_instance.postgres.address
    db_name       = aws_db_instance.postgres.db_name
    aws_region    = var.aws_region
  })

  # user_data only runs on first boot, so recreate the instance when it changes
  user_data_replace_on_change = true

  # Require IMDSv2 (blocks SSRF-style credential theft)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "devops-app"
  }
}

resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app_tg.arn

  target_id = aws_instance.app.id

  port = 3000
}