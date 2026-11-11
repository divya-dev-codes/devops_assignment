#!/bin/bash
set -euo pipefail

# Install Docker and jq (works on Amazon Linux 2 and 2023)
yum update -y
yum install -y docker jq

systemctl enable --now docker
usermod -aG docker ec2-user

# Fetch DB credentials from Secrets Manager.
# Retry because the instance role credentials can take a moment to become available.
for i in $(seq 1 10); do
  SECRET=$(aws secretsmanager get-secret-value \
    --secret-id "${db_secret_arn}" \
    --region "${aws_region}" \
    --query SecretString --output text) && break
  sleep 10
done

DB_USER=$(echo "$SECRET" | jq -r .username)
DB_PASSWORD=$(echo "$SECRET" | jq -r .password)

# Write an env file readable only by root, so the password never appears
# in `docker inspect` output or the process list
umask 077
cat > /etc/devops-app.env <<EOF
DB_HOST=${db_host}
DB_PORT=5432
DB_NAME=${db_name}
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
EOF
unset SECRET DB_PASSWORD

# Pull and run the application
docker pull divya123/devops-app:latest

docker run -d \
  --name devops-app \
  -p 3000:3000 \
  --env-file /etc/devops-app.env \
  --restart always \
  divya123/devops-app:latest