# 🚀 AWS Microservices Lift-and-Shift Deployment  
### Docker • EC2 • ALB • Auto Scaling • Terraform

![AWS](https://img.shields.io/badge/AWS-Cloud-orange)
![Terraform](https://img.shields.io/badge/IaC-Terraform-purple)
![Docker](https://img.shields.io/badge/Container-Docker-blue)
![Status](https://img.shields.io/badge/Status-Completed-success)

---

## 📌 Overview

This project demonstrates a minimal end-to-end migration of containerized services from local Docker development to a scalable AWS infrastructure using Terraform.

The goal was to:

- Push Docker images to **Amazon ECR**
- Deploy services on **EC2 instances**
- Orchestrate containers using **docker-compose**
- Expose services via an **Application Load Balancer (ALB)**
- Implement **Auto Scaling**
- Automate validation with a health verification script
- Provision infrastructure using **Terraform**

This simulates a real-world DevOps lift-and-shift migration scenario.

---

## 🏗️ Architecture

### 🔄 Architecture Flow

1. Docker images pushed to **Amazon ECR**
2. EC2 instances pull images via **Launch Template user-data**
3. Containers start automatically using `docker-compose`
4. ALB routes traffic:
   - `/service1/*` → Target Group 1 → Port 8080
   - `/service2/*` → Target Group 2 → Port 8081
5. Auto Scaling Group maintains capacity (CPU > 40%)

---

## 🌎 AWS Environment

| Component | Configuration |
|------------|--------------|
| AWS Region | us-east-1 |
| VPC CIDR | 10.0.0.0/16 |
| Subnets | 2 Public Subnets |
| EC2 Type | t2.micro |
| Load Balancer | Application Load Balancer |
| Scaling Policy | TargetTracking (CPU 40%) |
| Health Check | `/health` |

---

## 📁 Repository Structure

```
.
├── docker-compose.yml
├── verify_endpoints.sh
├── README.md
│
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── user_data.sh
    └── terraform.tfvars
```

---

# 🐳 Stage 1 – Push Docker Images to ECR

### 1️⃣ Create Repositories

```bash
aws ecr create-repository --repository-name service1
aws ecr create-repository --repository-name service2
```

### 2️⃣ Authenticate Docker

```bash
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

### 3️⃣ Tag & Push

```bash
docker tag service1:latest <ECR_URI>/service1:latest
docker push <ECR_URI>/service1:latest

docker tag service2:latest <ECR_URI>/service2:latest
docker push <ECR_URI>/service2:latest
```

### ✔ Verification

```bash
docker pull <ECR_URI>/service1:latest
```

---

# 🌍 Stage 2 – Infrastructure Deployment (Terraform)

Navigate to Terraform directory:

```bash
cd terraform
```

### Initialize

```bash
terraform init
```

### Plan

```bash
terraform plan
```

### Apply

```bash
terraform apply
```

After deployment:

```bash
terraform output alb_dns
```

---

# 🔁 Traffic Routing

| Path | Target |
|------|--------|
| `/service1/*` | Service 1 (Port 8080) |
| `/service2/*` | Service 2 (Port 8081) |

### Test via curl

```bash
curl http://<ALB-DNS>/service1/health
curl http://<ALB-DNS>/service2/health
```

Expected response:

```
HTTP 200
```

---

# 🔎 Endpoint Verification Script

Run:

```bash
chmod +x verify_endpoints.sh
./verify_endpoints.sh <ALB-DNS>
```

### Script Behavior

- Validates both service endpoints
- Exits with non-zero status on failure
- Prints confirmation when successful

---

# ⚙️ Auto Scaling Configuration

### Launch Template
- Ubuntu 24.04
- Docker installation
- AWS CLI installation
- Automatic ECR login
- docker-compose deployment

### Auto Scaling Group

| Setting | Value |
|----------|-------|
| Min | 2 |
| Desired | 2 |
| Max | 4 |

### Scaling Policy

- TargetTrackingScaling
- ASGAverageCPUUtilization
- Threshold: 40%

---

## 🔥 Load Simulation

```bash
sudo apt install stress
stress --cpu 2 --timeout 600
```

Monitor in:

- ASG Activity History
- CloudWatch Metrics

---

# 🔐 Security Design

- ALB security group: allows HTTP (80)
- EC2 security group:
  - 8080–8081 from ALB only
  - SSH (22) from personal IP
- Outbound traffic allowed (0.0.0.0/0)
- IAM role for EC2 provides ECR access

---

# 📊 Evidence Included

Submission contains screenshots of:

- ECR repositories
- `docker ps` on EC2
- ALB DNS curl response
- ASG scale-out events
- CloudWatch CPU graph

---

# 🧹 Cleanup

Destroy all resources:

```bash
cd terraform
terraform destroy
```

Confirmed removed:

- EC2 instances
- Auto Scaling Group
- Launch Template
- ALB
- Target Groups
- VPC
- Security Groups

---

# 🚀 Future Improvements

- Migrate to ECS or EKS
- Enable HTTPS with ACM
- Implement CI/CD pipeline
- Remote Terraform backend (S3 + DynamoDB)
- Structured logging & monitoring

---

# 🎯 Skills Demonstrated

- Docker image lifecycle
- Amazon ECR integration
- Terraform infrastructure provisioning
- EC2 bootstrapping via user-data
- ALB path-based routing
- Auto Scaling configuration
- Health check automation
- Secure cloud networking

---

## 👤 Author

**Praktan Taiwade**  
Cloud / DevOps / Network Engineer  
GitHub: https://github.com/praktan20

---
