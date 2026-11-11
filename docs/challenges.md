# Challenges and Lessons Learned

## 1\. Terraform Environment Setup

### Challenge

One of the first challenges was getting Terraform available consistently across the development environments.

Terraform initially worked locally but was not automatically available inside the Codespace environment.

This demonstrated that installing a tool on a local computer does not automatically make the same tool available inside a remote development environment.

### Resolution

Terraform was installed and verified in the environment where the project commands were actually being executed.

After the environment was configured, Terraform commands such as validation, planning, and infrastructure deployment could be executed from the Terraform project directory.

### Lesson Learned

DevOps tools must be installed and configured in the actual execution environment, not merely on the developer's local computer.

---

## 2\. AWS Authentication and Credentials

### Challenge

AWS CLI operations initially failed because AWS credentials were not configured for the execution environment.

This blocked Terraform and AWS CLI operations that required authenticated AWS API access.

### Resolution

AWS CLI access was configured and AWS identity access was verified before continuing with infrastructure provisioning.

Sensitive credentials were treated separately from application source code.

### Lesson Learned

Cloud authentication should be verified early in the project before debugging infrastructure configuration. Otherwise, authentication errors can easily be confused with Terraform or AWS resource errors.

---

## 3\. Terraform State Management

### Challenge

Terraform state management was initially confusing because it was not clear why an S3 backend and locking mechanism were needed in addition to normal Terraform configuration files.

### Resolution

Remote state was configured using an S3 backend with:

- devops\-assignment\-tfstate
- terraform.tfstate
- ap\-south\-1

A DynamoDB locking table named terraform\-locks was also included in the state\-management setup.

### Lesson Learned

Terraform configuration defines the desired infrastructure, while Terraform state tracks the relationship between that configuration and the real infrastructure.

Keeping state outside the local workspace makes infrastructure management safer and more consistent.

---

## 4\. Terraform Project Structure

### Challenge

As infrastructure requirements grew to include networking, compute, security, load balancing, IAM, and database resources, keeping all configuration together became difficult to understand.

### Resolution

Terraform configuration was separated into logical files according to infrastructure responsibility.

This made networking, EC2, load\-balancer, RDS, security, provider, variable, output, and IAM configuration easier to locate and troubleshoot.

### Lesson Learned

Infrastructure as Code should be organized for readability and maintainability rather than putting every resource into one large configuration file.

---

## 5\. Docker Port Conflict

### Challenge

While testing the Node.js application, port 3000 was already in use and the application could not start another listener on the same port.

### Resolution

Running processes/containers and their port mappings were checked before starting additional application instances.

Docker container status and port mappings were verified using Docker commands before retesting the application.

### Lesson Learned

When a service reports that an address or port is already in use, the existing process or container should be identified before restarting services.

---

## 6\. Docker Compose Execution Location

### Challenge

Docker Compose commands were executed from the application directory, but Docker reported that no Compose configuration file could be found.

### Resolution

The project structure and current working directory were checked to determine where the relevant configuration existed and whether the application was being run as an individual Docker container or through Compose.

### Lesson Learned

The current working directory matters. DevOps commands often expect configuration files in the current directory unless another path is explicitly provided.

---

## 7\. Prometheus Connectivity

### Challenge

Prometheus monitoring required connectivity between the Prometheus container and the application metrics endpoint.

At one stage, the Node.js target returned a connection\-refused error even though other monitoring targets were available.

### Resolution

The application container, exposed port, metrics endpoint, and Prometheus target configuration were checked together.

The troubleshooting process demonstrated the difference between an application working in a browser and a monitoring container being able to reach that application from its own network context.

### Lesson Learned

Container networking must be considered from the perspective of the container making the request. localhost inside one container does not automatically represent another container or the host.

Monitoring should therefore be validated from the actual Prometheus target\-health screen rather than assuming a working application means the scrape target is healthy.

---

## 8\. Grafana and Prometheus Integration

### Challenge

Having Grafana and Prometheus running did not automatically provide useful monitoring dashboards.

Grafana still needed a Prometheus data source and meaningful queries/panels.

### Resolution

Prometheus was configured as the Grafana data source and dashboards/panels were created for infrastructure and application monitoring.

The resulting dashboards provide visual representations of collected metrics.

### Lesson Learned

Collecting metrics and visualizing metrics are separate responsibilities. Prometheus collects/query metrics while Grafana provides the visualization layer.

---

## 9\. Building the CI/CD Pipeline

### Challenge

The pipeline had to provide more than a simple Docker build. The assignment required code validation, tests, security scanning, registry delivery, staging deployment, production controls, and failure notifications.

### Resolution

GitHub Actions was used to connect source\-control events with CI/CD tasks.

The deployment workflow incorporated AWS authentication, ECR login, Docker image building/tagging/pushing, Terraform initialization, and Terraform deployment.

Separate controls were considered for pull\-request checks, staging deployment, and production approval.

### Lesson Learned

A CI/CD pipeline should be designed around software lifecycle events rather than treated as a single deployment script.

Pull requests, merges to main, staging releases, and production releases have different risk levels and therefore require different controls.

---

## 10\. Container and Dependency Vulnerabilities

### Challenge

Container security scanning identified the need to consider vulnerabilities in both the application dependency tree and the Docker image.

### Resolution

Trivy was included in the security\-scanning workflow and the Docker configuration was refined during security testing.

### Lesson Learned

A successfully running container is not necessarily a secure container.

Security scanning needs to happen before deployment and should be part of the normal CI/CD process rather than a one\-time manual check.

---

## 11\. Amazon ECR and Image Deployment

### Challenge

Building the Docker image locally was only one part of deployment. The image also needed to be authenticated, tagged correctly, pushed to Amazon ECR, and then used by the AWS environment.

### Resolution

The CI/CD workflow performs AWS configuration, ECR authentication, Docker image building/tagging, and image push operations.

ECR was then verified to contain the deployment image.

### Lesson Learned

Container deployment involves an image lifecycle:

**Build → Scan → Tag → Push → Pull/Deploy → Run**

Verifying each stage individually makes container\-deployment failures easier to isolate.

---

## 12\. Application Load Balancer Verification

### Challenge

A running application on EC2 did not by itself prove that the public deployment architecture was working.

The application needed to be tested both locally on the EC2 instance and through the Application Load Balancer.

### Resolution

The application was first tested through port 3000 on the EC2 environment and then accessed through the ALB DNS endpoint.

The successful ALB response demonstrated the complete request path:

**Client → ALB → EC2 → Docker → Node.js**

### Lesson Learned

Deployment verification should test the same entry point that an actual client uses, not only the application process internally.

---

## 13\. Slack Failure Notifications

### Challenge

The assignment required a Slack or email notification when the CI pipeline failed, but Slack was not initially configured for the project.

### Resolution

Slack integration was added so the CI process could send failure notifications.

### Lesson Learned

Pipeline observability is also important. A CI/CD system should not only execute automation but also notify maintainers when automation fails.

---

## 14\. Secret Management

### Challenge

The project required sensitive AWS and deployment information while also requiring that secrets remain outside the application repository.

### Resolution

Secret management was implemented rather than embedding sensitive values directly into application source code.

IAM\-based access and controlled secret usage were incorporated into the AWS/deployment design.

Repository security practices were also applied to prevent credentials and sensitive local files from being committed.

### Lesson Learned

Secrets should be separated from application code and provided only to the systems and workloads that require them.

---

## 15\. Documentation and Evidence

### Challenge

A working deployment alone does not clearly demonstrate that every assignment requirement has been completed.

CI/CD, Terraform, AWS resources, monitoring, security, and deployment results all require evidence.

### Resolution

Documentation was divided into:

- README.md for project setup, deployment, security, and usage
- docs/approach.md for implementation strategy
- docs/architecture.md for system architecture and design decisions
- docs/challenges.md for troubleshooting and lessons learned
- docs/Screenshots/ for implementation evidence

### Lesson Learned

Documentation should be created alongside a DevOps project rather than after everything else is finished. Good documentation explains not only what was built, but why decisions were made and how problems were solved.

---

## Conclusion

The most important lesson from this project was that DevOps is not one individual technology.

The final solution required application development, Docker, Terraform, AWS networking, EC2, RDS, ECR, load balancing, IAM and secret handling, GitHub Actions, vulnerability scanning, Prometheus, Grafana, and CI notifications to work together.

Troubleshooting each layer individually and then verifying the complete end\-to\-end path made the project manageable and provided a clearer understanding of how a complete DevOps delivery system operates.

