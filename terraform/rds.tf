resource "aws_db_subnet_group" "postgres" {
  name = "postgres-subnet-group"

  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]
}

resource "aws_db_instance" "postgres" {
  identifier        = "devops-postgres"
  allocated_storage = 20
  storage_type      = "gp2"

  engine         = "postgres"
  engine_version = "15"

  instance_class = "db.t3.micro"

  db_name = "appdb"

  username = var.db_username
  password = var.db_password

  publicly_accessible = false

  backup_retention_period = 7
  deletion_protection     = true

  db_subnet_group_name = aws_db_subnet_group.postgres.name

  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]

  skip_final_snapshot = true
}