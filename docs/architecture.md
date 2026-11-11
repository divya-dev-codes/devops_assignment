
# Architecture

## 1. Architecture Overview

The project uses a container-based AWS architecture managed through Terraform and deployed through GitHub Actions.

The solution separates the system into five logical layers:

1. Source control and CI/CD
2. AWS networking
3. Application and container deployment
4. Database and secrets
5. Monitoring and observability

---

## 2. High-Level Architecture

The application delivery flow is:

**Developer → GitHub → GitHub Actions → Docker → Amazon ECR → AWS EC2**

Application traffic follows:

**Client → Application Load Balancer → EC2 → Docker Container → Node.js Application**

Monitoring follows:

**Node.js / EC2 Metrics → Prometheus → Grafana**

The database layer is provided using:

**Application → Database Security Controls → Amazon RDS PostgreSQL**

---

## 3. AWS Network Architecture

The infrastructure is deployed inside a custom VPC in the `ap-south-1` AWS region.

The VPC contains:

- Two public subnets
- Two private subnets
- Internet Gateway
- Route tables and associations
- Security groups

The separation of public and private subnets provides a cleaner security boundary between externally reachable infrastructure and internal resources.

The Application Load Balancer handles incoming application traffic and forwards requests toward the application target.

Private networking is used for components that should not require direct exposure to the internet, including the database layer.

---

## 4. Compute Architecture

Amazon EC2 was selected as the compute platform for the assignment.

The EC2 instance hosts the Dockerized Node.js application.

The containerized application listens on port `3000`, and its execution was verified directly on the EC2 host.

Using Docker provides a consistent application runtime between development, testing, CI/CD, and AWS deployment.

---

## 5. Load Balancer Architecture

An AWS Application Load Balancer sits in front of the application.

The request flow is:

**User Request → ALB Listener → Target Group → EC2 → Docker → Express Application**

This design prevents users from needing to connect directly to the application's container port.

The application exposes a `/health` endpoint that can support application health verification.

---

## 6. Database Architecture

Amazon RDS PostgreSQL provides the relational database component required by the infrastructure specification.

The database layer is separated from the public-facing application layer.

Database access is controlled using networking and security groups so that the database does not need to be treated as an internet-facing service.

This architecture follows the principle that only components requiring public access should receive public-facing connectivity.

---

## 7. Container Architecture

The Node.js application is packaged as a Docker image.

Amazon ECR is the image registry.

The container lifecycle is:

**Source Code → Docker Build → Vulnerability Scan → ECR → EC2 Container**

The running application container publishes port `3000`.

ECR provides a central AWS location from which the deployment environment can obtain the application image.

---

## 8. CI/CD Architecture

GitHub Actions provides CI/CD automation.

The pipeline separates code validation from deployment.

### Pull Request Flow

**Pull Request → Tests → Security Checks → Merge Decision**

The purpose of the PR workflow is to detect application or security problems before code enters the main deployment branch.

### Main Branch Flow

**Merge to Main → Build Image → Authenticate to AWS/ECR → Push Image → Terraform → Staging Deployment**

Staging deployment is automated.

Production promotion uses a manual approval mechanism so production changes require an explicit decision before deployment.

Pipeline failure notifications are integrated with Slack.

---

## 9. Monitoring Architecture

The monitoring stack contains:

### Prometheus

Prometheus collects metrics from configured targets.

### Node Exporter

Node Exporter provides host-level metrics for infrastructure monitoring.

### Application Metrics

The Node.js application uses `prom-client` and exposes Prometheus-compatible metrics through:

`/metrics`

Application metrics include HTTP request and latency-related observations in addition to runtime metrics.

### Grafana

Grafana is connected to Prometheus as a data source.

Grafana dashboards provide visual monitoring of infrastructure and application metrics.

Conceptually:

**EC2 / Node Exporter ─┐**

**Node.js /metrics ────┼→ Prometheus → Grafana Dashboards**

**Prometheus Metrics ──┘**

Multiple Grafana dashboards/panels are used to present application and infrastructure monitoring information.

---

## 10. Terraform Architecture

Terraform manages AWS infrastructure declaratively.

The project separates Terraform configuration according to responsibility, including networking, EC2, load balancing, security, IAM, database resources, providers, variables, outputs, and backend configuration.

This separation improves readability and makes individual infrastructure responsibilities easier to maintain.

### State Architecture

Terraform state is managed remotely using an S3 backend.

Configured state information includes:

- Bucket: `devops-assignment-tfstate`
- Key: `terraform.tfstate`
- Region: `ap-south-1`

A DynamoDB locking table named `terraform-locks` was also incorporated into the project state-management configuration.

---

## 11. Security Architecture

Security is implemented in multiple layers.

### Network Security

Security groups control allowed communication between infrastructure components.

### Secret Management

Secrets are kept separate from application source code and should never be committed to GitHub.

AWS access controls and CI/CD secret storage are used according to the component that requires the sensitive value.

### Image and Dependency Security

Trivy provides vulnerability scanning within the development/CI workflow.

This adds security checks before vulnerable application/container changes are promoted.

### Deployment Security

Staging can be automatically deployed while production requires manual approval.

This creates a deployment control between automated validation and the production environment.

---

## 12. Architecture Decisions

### Why EC2?

EC2 was selected instead of ECS or EKS because the assignment requires a single containerized application and EC2 provides direct control over the host while keeping the infrastructure understandable and demonstrable.

EKS would introduce additional orchestration complexity that is unnecessary for the scope of this project.

### Why Docker?

Docker creates a repeatable application environment and simplifies movement of the application from development to CI/CD and finally AWS.

### Why ECR?

ECR integrates the container image registry with the AWS deployment environment.

### Why Terraform?

Terraform makes the AWS infrastructure reproducible, reviewable, and manageable as code.

### Why GitHub Actions?

The source repository is hosted on GitHub, making GitHub Actions a direct way to connect repository events with testing and deployment automation.

### Why Prometheus and Grafana?

Prometheus provides metrics collection while Grafana provides visualization. Combined with Node Exporter and application instrumentation, they cover both host-level and application-level observability.

### Why RDS PostgreSQL?

RDS PostgreSQL satisfies the project's relational database requirement while separating database management from the application host.

---

## 13. Architecture Summary

The final architecture combines:

**Terraform + AWS VPC + Public/Private Subnets + Security Groups + ALB + EC2 + Docker + ECR + RDS PostgreSQL + Secret Management + GitHub Actions + Trivy + Prometheus + Node Exporter + Grafana + Slack Notifications**

The architecture provides a complete path from code change through validation, container delivery, AWS deployment, security controls, and monitoring.