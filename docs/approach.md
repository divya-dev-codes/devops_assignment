# Project Approach

## 1. Introduction

This project was implemented as an end-to-end DevOps solution for deploying, securing, automating, and monitoring a containerized Node.js application on AWS.

The implementation was divided into four major areas:

1. Infrastructure provisioning using Terraform
2. CI/CD automation using GitHub Actions
3. Monitoring and observability using Prometheus and Grafana
4. Security, secret management, and project documentation

The main objective was to avoid manual infrastructure configuration where possible and create a deployment process that is repeatable, automated, observable, and secure.

---

## 2. Infrastructure Approach

Terraform was selected as the Infrastructure as Code tool so that AWS infrastructure could be defined in configuration files and reproduced consistently.

The infrastructure was organized into separate Terraform files for networking, security, compute, load balancing, database resources, IAM, variables, providers, outputs, and backend/state configuration.

### Networking

A custom AWS VPC was created as the network boundary for the application.

The network design includes:

- Two public subnets
- Two private subnets
- Internet Gateway
- Route tables
- Route table associations
- Security groups

Public and private subnets were used to provide network separation between externally reachable components and resources that should not require direct public exposure.

### Application Hosting

Amazon EC2 was selected for application hosting.

The Node.js application is packaged as a Docker container and runs on the EC2 instance on port `3000`.

The EC2 deployment was verified directly from the instance using the application endpoint and through the Application Load Balancer.

### Load Balancing

An AWS Application Load Balancer is used as the application entry point.

The ALB forwards client traffic to the application running on EC2. A target group connects the load balancer to the application instance.

The final application path is:

Client → Application Load Balancer → EC2 → Docker → Node.js Application

### Database

Amazon RDS PostgreSQL is used for the database component of the infrastructure.

Database-related Terraform resources are separated from application and network resources to make the infrastructure easier to understand and maintain.

The database is associated with private networking and database-specific security controls rather than being treated as a publicly exposed application component.

### Security Groups

Security groups are used to control network access between the different infrastructure components.

The design separates access based on the responsibility of each component instead of relying on unrestricted network access.

### Terraform Variables and Outputs

Reusable and environment-dependent values are handled through Terraform variables rather than unnecessarily hard-coding values throughout the infrastructure.

Terraform outputs are used to expose useful deployment information after infrastructure provisioning, such as the load balancer endpoint.

### Terraform State Management

Remote Terraform state management was configured using an Amazon S3 backend.

The project backend configuration uses:

- S3 bucket: `devops-assignment-tfstate`
- State key: `terraform.tfstate`
- AWS region: `ap-south-1`

A DynamoDB table named `terraform-locks` was also incorporated into the state-management setup.

This separates Terraform state from the developer workspace and provides centralized state management for the infrastructure.

---

## 3. Application and Containerization Approach

The application is built using Node.js and Express.

The application exposes:

- `/` for the main application response
- `/health` for health checking
- `/metrics` for Prometheus metrics

Docker is used to package the application and its required runtime into a consistent deployable image.

The container exposes port `3000`, matching the application listening port.

Amazon Elastic Container Registry is used as the container registry for deployment images.

The image flow is:

Application Source → Docker Build → Security Scan → Amazon ECR → EC2

This ensures that the application deployed to AWS uses a defined container image rather than requiring the application environment to be assembled manually on the server.

---

## 4. CI/CD Approach

GitHub Actions was selected as the CI/CD platform because the application source code and project configuration are maintained in GitHub.

The pipeline is designed around two important Git events.

### Pull Request Validation

Pull requests are used as a quality gate before code reaches the main branch.

The CI process includes application validation/testing and security checks so that problems can be identified before changes are merged.

The project includes:

- Unit/integration testing workflow work
- Dependency/filesystem vulnerability scanning
- Container security scanning using Trivy

### Main Branch Deployment

Changes merged into the main branch move through the deployment workflow.

The deployment flow includes:

1. Checkout source code
2. Configure AWS authentication
3. Authenticate with Amazon ECR
4. Build the Docker image
5. Tag the Docker image
6. Push the Docker image to ECR
7. Configure Terraform
8. Initialize Terraform
9. Apply the infrastructure/deployment configuration
10. Deploy to the staging environment

This provides an automated path from source control to the AWS staging environment.

### Production Safety

Production deployment is treated separately from automatic staging deployment.

The deployment design includes a manual approval requirement before production so that merging code does not automatically promote an unreviewed deployment into production.

### Failure Notification

CI/CD failure notification was integrated with Slack.

The purpose of this notification is to provide visibility when pipeline execution fails instead of requiring the repository owner to continuously monitor GitHub Actions manually.

---

## 5. Security Approach

Security was included at multiple points rather than being treated as a final deployment step.

### Vulnerability Scanning

Trivy is used as part of the project security checks.

Security scanning covers dependency/filesystem and container-related vulnerabilities as part of the development and pipeline process.

### Secret Management

Secret management was selected as the additional security implementation for the assignment.

Sensitive information should not be stored directly in application source code or committed to GitHub.

AWS IAM and secret-access controls are used as part of the AWS architecture, while CI/CD credentials and notification secrets are kept outside application source code.

This reduces the risk of credentials becoming part of repository history.

### Repository Security

Files containing credentials, local state, environment-specific secrets, or generated artifacts should not be committed to the repository.

The `.gitignore` file is used as an additional repository-level safeguard.

---

## 6. Monitoring and Observability Approach

Prometheus and Grafana were selected for application and infrastructure monitoring.

The monitoring stack includes:

- Prometheus
- Grafana
- Node Exporter
- Node.js `prom-client`

The Node.js application exposes Prometheus metrics through `/metrics`.

Metrics configured in the application include application/runtime metrics, HTTP request counts, and HTTP request latency observations.

Node Exporter provides host-level metrics, and Prometheus collects metrics from the configured monitoring targets.

Grafana uses Prometheus as its data source and provides dashboards for visualizing collected metrics.

The monitoring implementation is designed to provide visibility into categories required by the assignment, including infrastructure and application behavior.

Multiple Grafana dashboards/panels were created to visualize application and infrastructure metrics.

---

## 7. Logging Approach

Logging is considered at multiple layers of the system:

- Application/container logs
- EC2/system-level logs
- Application/load-balancer access information

These logs complement Prometheus metrics by providing diagnostic information when investigating failures or unexpected behavior.

For a production implementation, these sources can be forwarded into a dedicated centralized log-management platform for long-term retention, searching, and alerting.

---

## 8. Cost Optimization

The project is designed as an assignment/demo environment rather than a high-scale production architecture.

Cost is controlled by:

- Using EC2 instead of introducing a larger container-orchestration platform where it is not required
- Containerizing the application so the EC2 environment remains simple
- Keeping the architecture appropriately sized for a demonstration workload
- Destroying unused Terraform-created infrastructure after testing
- Avoiding unnecessary always-running resources

Terraform also makes cleanup easier because managed infrastructure can be removed consistently when the environment is no longer required.

---

## 9. Final Result

The project combines Infrastructure as Code, automated CI/CD, containerization, AWS deployment, vulnerability scanning, secret management, monitoring, and documentation into a single DevOps workflow.

The deployed application has been verified through the following path:

GitHub → CI/CD → Docker → Amazon ECR → AWS Infrastructure → EC2 → Application Load Balancer → Application

Prometheus and Grafana provide the observability layer, while Terraform makes the infrastructure reproducible and GitHub Actions automates application delivery.