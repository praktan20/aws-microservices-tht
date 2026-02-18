🚀 AWS Microservices Lift-and-Shift Deployment (Docker + EC2 + ALB + ASG + Terraform)
📌 Project Overview

This project demonstrates a minimal end-to-end cloud migration of containerized services from local Docker development to a scalable AWS infrastructure using Terraform.

The objective was to:

Push Docker images to Amazon ECR

Deploy services on EC2 instances

Orchestrate containers using docker-compose

Expose services through an Application Load Balancer (ALB)

Implement Auto Scaling

Automate validation with a health verification script

Provision all infrastructure using Terraform

This simulates a time-boxed DevOps proof-of-concept migration from a legacy monolith to a containerized microservices architecture.

🏗️ Architecture Diagram
4
🔄 Architecture Flow

Docker images are pushed to Amazon ECR

EC2 instances pull images during boot via Launch Template user-data

Containers run using docker-compose

ALB routes traffic:

/service1/* → Target Group 1 → Port 8080

/service2/* → Target Group 2 → Port 8081

Auto Scaling Group maintains capacity and scales when:

CPU utilization > 40% for 5 minutes

🌎 AWS Environment Details
Component	Configuration
AWS Region	us-east-1
VPC CIDR	10.0.0.0/16
Subnets	2 Public Subnets
EC2 Type	t2.micro
Load Balancer	Application Load Balancer
Scaling Policy	TargetTracking (CPU 40%)
Health Check	/health
📁 Repository Structure
.
├── docker-compose.yml
├── verify_endpoints.sh
├── README.md
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── user_data.sh
│   └── terraform.tfvars

🐳 Stage 1 – Push Docker Images to Amazon ECR

Create repositories:

aws ecr create-repository --repository-name service1
aws ecr create-repository --repository-name service2


Authenticate Docker:

aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com


Tag & Push:

docker tag service1:latest <ECR_URI>/service1:latest
docker push <ECR_URI>/service1:latest

docker tag service2:latest <ECR_URI>/service2:latest
docker push <ECR_URI>/service2:latest


Verify:

docker pull <ECR_URI>/service1:latest

🌍 Stage 2 – Deploy Infrastructure (Terraform)

Navigate to Terraform directory:

cd terraform


Initialize:

terraform init


Plan:

terraform plan


Apply:

terraform apply


After successful deployment:

terraform output alb_dns


This returns the ALB DNS endpoint.

🔁 Traffic Routing
Path	Target
/service1/*	Service 1 (Port 8080)
/service2/*	Service 2 (Port 8081)

Example:

curl http://<ALB-DNS>/service1/health
curl http://<ALB-DNS>/service2/health


Expected response:

HTTP 200

🔎 Endpoint Verification Script

verify_endpoints.sh

Run:

chmod +x verify_endpoints.sh
./verify_endpoints.sh <ALB-DNS>


Script behavior:

Validates both service endpoints

Exits with non-zero status on failure

Prints confirmation when successful

⚙️ Auto Scaling Implementation
Launch Template

Ubuntu 24.04

Docker & AWS CLI installation

Automatic ECR login

docker-compose deployment via user-data

Auto Scaling Group
Setting	Value
Min	2
Desired	2
Max	4
Scaling Policy

TargetTrackingScaling

ASGAverageCPUUtilization

Threshold: 40%

Simulate Load

SSH into instance:

sudo apt install stress
stress --cpu 2 --timeout 600


Observe scale-out in:

ASG Activity History

CloudWatch Metrics

🔐 Security Design

ALB security group allows public HTTP (80)

EC2 security group allows:

8080–8081 from ALB only

SSH (22) from personal IP

Outbound traffic allowed (0.0.0.0/0)

EC2 IAM role allows ECR access

📊 Evidence Provided

Submission includes screenshots of:

ECR repositories

docker ps on EC2

ALB DNS endpoint with curl response

Auto Scaling event logs

CloudWatch CPU metric graph

🧹 Cleanup Instructions

To destroy all AWS resources:

cd terraform
terraform destroy


All resources confirmed deleted:

EC2 instances

Auto Scaling Group

Launch Template

ALB

Target Groups

VPC

Security Groups

No running billable resources remain.
