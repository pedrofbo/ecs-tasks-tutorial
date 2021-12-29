#!/bin/bash

set -e

echo " > Installing Docker..."
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
echo " > Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo " > Creating Airflow services..."
mkdir -p ./logs
cp /home/ubuntu/.config/ecs-tasks-tutorial/.env ./.env
echo -e "AIRFLOW_UID=$(id -u)\nAIRFLOW_GID=0" >> .env
sudo docker-compose down
sudo docker-compose up airflow-init

echo " > Successful setup. Starting Airflow services..."
sudo docker-compose up -d
