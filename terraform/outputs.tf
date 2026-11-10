output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_1_id" {
  description = "Public Subnet 1 ID"
  value       = aws_subnet.public_subnet_1.id
}

output "public_subnet_2_id" {
  description = "Public Subnet 2 ID"
  value       = aws_subnet.public_subnet_2.id
}

output "ec2_instance_id" {
  description = "Application EC2 Instance ID"
  value       = aws_instance.app.id
}

output "ec2_public_ip" {
  description = "Application EC2 Public IP"
  value       = aws_instance.app.public_ip
}

output "alb_dns" {
  description = "Application Load Balancer DNS"
  value       = aws_lb.app_lb.dns_name
}

output "application_url" {
  description = "Application URL"
  value       = "http://${aws_lb.app_lb.dns_name}"
}

output "rds_endpoint" {
  description = "PostgreSQL RDS Endpoint"
  value       = aws_db_instance.postgres.endpoint
}