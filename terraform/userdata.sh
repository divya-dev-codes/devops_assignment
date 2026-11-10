#!/bin/bash

# Update packages
yum update -y

# Install Docker
amazon-linux-extras install docker -y

systemctl start docker
systemctl enable docker

usermod -aG docker ec2-user

# Pull application image
docker pull YOUR_DOCKERHUB_USERNAME/devops-app:latest

# Run application
docker run -d \
  --name devops-app \
  -p 3000:3000 \
  --restart always \
  YOUR_DOCKERHUB_USERNAME/devops-app:latest