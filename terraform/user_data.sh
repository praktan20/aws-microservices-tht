#!/bin/bash
apt update
apt install -y docker.io docker-compose awscli
systemctl start docker

aws ecr get-login-password --region ${region} | \
docker login --username AWS --password-stdin ${ecr_uri}

cat <<EOF > /home/ubuntu/docker-compose.yml
version: '3.8'
services:
  service1:
    image: ${ecr_uri}/service1:latest
    ports:
      - "8080:8080"
  service2:
    image: ${ecr_uri}/service2:latest
    ports:
      - "8081:8081"
EOF

cd /home/ubuntu
docker compose up -d
