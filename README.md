# DevOps Assignment

## Overview

This project demonstrates an end-to-end DevOps workflow for a containerized Node.js application. The application is instrumented with Prometheus metrics, containerized with Docker, deployed on AWS infrastructure managed with Terraform, exposed through an Application Load Balancer (ALB), and monitored with Prometheus and Grafana.

The application listens on port `3000` and provides application, health-check, and metrics endpoints.

## Architecture

```text
Developer / GitHub
        |
        v
   CI/CD Pipeline
        |
        v
   Docker Image
        |
        v
   Amazon ECR
        |
        v
Application Load Balancer
        |
        v
      EC2
        |
        v
Dockerized Node.js App :3000
        |
        +---- /health
        |
        +---- /metrics ----> Prometheus ----> Grafana
```

AWS infrastructure is provisioned with Terraform in the `ap-south-1` (Mumbai) region.

## Technology Stack

- **Application:** Node.js, Express
- **Containerization:** Docker
- **Infrastructure as Code:** Terraform
- **Cloud:** AWS
- **Container Registry:** Amazon ECR
- **Compute:** Amazon EC2
- **Load Balancing:** AWS Application Load Balancer
- **Monitoring:** Prometheus, Grafana, Node Exporter
- **Application Metrics:** `prom-client`
- **Source Control / CI/CD:** GitHub and GitHub workflow automation
- **Security Scanning:** Trivy

## Application Endpoints

| Endpoint | Purpose |
|---|---|
| `/` | Main application response |
| `/health` | Health-check endpoint for the AWS ALB |
| `/metrics` | Prometheus metrics endpoint |

The application binds to `0.0.0.0` on port `3000`, allowing the containerized service to receive network traffic.

## Application Monitoring

The Node.js application uses `prom-client` to expose Prometheus-compatible metrics.

Configured metrics include:

- Default Node.js process/runtime metrics
- `http_requests_total` for HTTP request counts
- `http_request_duration_seconds` for request-duration observations

Prometheus scraping requests to `/metrics` are excluded from the custom HTTP request middleware so monitoring traffic does not inflate the application request metric.

## AWS Infrastructure

Terraform is used to manage the AWS infrastructure. The project work includes:

- VPC
- 2 public subnets
- 2 private subnets
- Internet Gateway
- Route tables
- EC2 compute
- Application Load Balancer
- Amazon ECR integration

The configured AWS region is:

```text
ap-south-1
```

### Terraform State

Remote Terraform state was configured using an S3 backend:

```text
Bucket: devops-assignment-tfstate
Key:    terraform.tfstate
Region: ap-south-1
```

A DynamoDB table named `terraform-locks` was also used in the state-management configuration during the project setup.

> Never commit AWS credentials, Terraform state containing sensitive values, `.env` secrets, or private keys to the repository.

## Docker

The Node.js application is packaged as a Docker image and runs with container port `3000` published to the host.

Example local build:

```bash
cd app
docker build -t devops-app .
```

Example local run:

```bash
docker run -d --name devops-app -p 3000:3000 devops-app
```

Verify the running container:

```bash
docker ps
```

Test the application:

```bash
curl http://localhost:3000
```

Test the health endpoint:

```bash
curl http://localhost:3000/health
```

Test Prometheus metrics:

```bash
curl http://localhost:3000/metrics
```

## Amazon ECR

The deployment workflow uses Amazon Elastic Container Registry (ECR) to store the application Docker image. The deployed EC2 container has been observed running an ECR-hosted image tagged `latest`.

Typical image-delivery flow:

```text
Build -> Scan -> Tag -> Push to ECR -> Deploy/Run on EC2
```

## CI/CD and Security Scanning

The project includes a GitHub-based CI/CD workflow. During the project, the pipeline work covered application dependency/test steps, Docker image processing, Trivy filesystem/container security scanning, and an ECR image delivery flow.

Before considering a pipeline run successful, verify all required workflow jobs are green in the GitHub Actions interface.

## Monitoring with Prometheus and Grafana

The monitoring environment includes:

- **Prometheus** for metrics collection
- **Grafana** for visualization
- **Node Exporter** for host-level metrics
- **Application `/metrics` endpoint** for Node.js/application metrics

During local monitoring setup, the services used these ports:

| Service | Port |
|---|---:|
| Node.js application | 3000 |
| Grafana | 3001 on the host, mapped to container port 3000 |
| Prometheus | 9090 |

### Prometheus Verification

Open the Prometheus interface and verify the configured scrape targets are healthy. Application metrics can also be checked directly with:

```bash
curl http://localhost:3000/metrics
```

### Grafana Verification

Use Grafana with Prometheus configured as a data source, then verify that the dashboard can query the expected application or host metrics.

## Deployment Verification

The final deployment was verified from the EC2 host and through the AWS Application Load Balancer.

The EC2 instance used during final verification had private IP:

```text
10.0.1.179
```

The following checks returned the application's success response:

```bash
curl http://localhost:3000
curl http://10.0.1.179:3000
```

The application was also successfully reached through the ALB DNS endpoint:

```text
devops-alb-268291321.ap-south-1.elb.amazonaws.com
```

At final verification, the `devops-app` Docker container was running and publishing port `3000`.

## Suggested Repository Structure

The exact repository may contain additional files, but a clear final structure should look similar to:

```text
devops_assignment/
├── .github/
│   └── workflows/
│       └── <workflow-file>.yml
├── app/
│   ├── Dockerfile
│   ├── package.json
│   ├── package-lock.json
│   └── server.js
├── monitoring/
│   └── <monitoring-configuration-files>
├── *.tf
├── .gitignore
└── README.md
```

Replace the angle-bracket filenames above with the actual filenames in the repository before final submission.

## Prerequisites

To reproduce the project, install and configure the tools used by the repository:

- Git
- Node.js and npm
- Docker
- Terraform
- AWS CLI
- An AWS account with the permissions required by the Terraform configuration and deployment workflow

Confirm the major command-line tools are available:

```bash
node --version
npm --version
docker --version
terraform version
aws --version
```

## Deployment Guide

### 1. Clone the repository

```bash
git clone <your-repository-url>
cd devops_assignment
```

### 2. Install application dependencies

```bash
cd app
npm install
```

### 3. Run the application locally

```bash
npm start
```

Then test:

```bash
curl http://localhost:3000
```

### 4. Build the Docker image

```bash
docker build -t devops-app .
```

### 5. Initialize Terraform

Run Terraform from the directory containing the `.tf` configuration files:

```bash
terraform init
```

### 6. Validate the Terraform configuration

```bash
terraform validate
```

### 7. Review the infrastructure plan

```bash
terraform plan
```

### 8. Provision infrastructure

```bash
terraform apply
```

Review the plan carefully before approving the apply operation.

### 9. Verify the deployed application

After deployment, verify:

1. The EC2 instance is running.
2. The application Docker container is running.
3. The ALB target is healthy.
4. The application responds through the ALB DNS name.
5. Prometheus can reach its configured targets.
6. Grafana can query the Prometheus data source.
7. The required GitHub Actions workflow completes successfully.

## Evidence / Screenshots

For assignment submission, include screenshots such as:

1. GitHub repository structure
2. Successful CI/CD workflow run
3. Terraform initialization/plan/apply result
4. AWS VPC/subnets or relevant Terraform-created infrastructure
5. EC2 instance
6. ECR repository/image
7. ALB and healthy target status
8. Running Docker container on EC2
9. Application responding through the ALB
10. Prometheus targets
11. Grafana dashboard
12. Trivy scan result

A recommended repository layout for evidence is:

```text
docs/
└── screenshots/
    ├── 01-repository.png
    ├── 02-cicd-success.png
    ├── 03-terraform.png
    ├── 04-aws-infrastructure.png
    ├── 05-ecr.png
    ├── 06-alb-target.png
    ├── 07-ec2-docker.png
    ├── 08-application-alb.png
    ├── 09-prometheus.png
    ├── 10-grafana.png
    └── 11-trivy.png
```

Add the screenshots to the repository and reference them from this README if required by the assignment.

## Cleanup

AWS resources can incur charges while they exist. When the project no longer needs to remain deployed, review the resources and destroy Terraform-managed infrastructure from the Terraform configuration directory:

```bash
terraform destroy
```

Confirm in the AWS Console that resources that are no longer required have been removed. Also review resources created outside Terraform separately.

## Security Notes

- Do not commit AWS access keys or secret keys.
- Do not commit `.env` files containing secrets.
- Keep sensitive Terraform files out of source control where appropriate.
- Use `.gitignore` to exclude generated/local artifacts and credentials.
- Rotate or revoke any credential that has been exposed in terminal output, screenshots, chat, or repository history.
- Review Trivy findings and remediate important vulnerabilities before production use.
- Prefer HTTPS for a production-facing application. The final test shown during this assignment used an HTTP ALB endpoint.

## Project Status

The core deployment path has been demonstrated successfully:

```text
Client -> AWS ALB -> EC2 -> Docker -> Node.js application
```

The application responded successfully from the EC2 host and through the ALB endpoint. Prometheus/Grafana monitoring and the CI/CD workflow were also configured during the project work. Final submission should include evidence of successful monitoring targets/dashboards and a successful required CI/CD workflow run.

## Conclusion

This project demonstrates a practical DevOps workflow combining application development, containerization, Infrastructure as Code, AWS deployment, CI/CD, security scanning, and observability. Terraform provides repeatable infrastructure provisioning, Docker packages the application consistently, AWS provides the deployment environment, and Prometheus/Grafana provide visibility into application and host behavior.

