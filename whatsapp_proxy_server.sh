#!/bin/bash

# Function to update system packages
update_system() {
    echo "Updating system packages..."
    if [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt upgrade -y || { echo "Update failed"; exit 1; }
    elif [ -f /etc/redhat-release ]; then
        sudo yum update -y || { echo "Update failed"; exit 1; }
    else
        echo "Unsupported Linux distribution."
        exit 1
    fi
}

# Function to install Docker
install_docker() {
    if ! command -v docker &> /dev/null; then
        echo "Docker is not installed. Installing Docker..."
        sudo apt install docker.io || { echo "Docker installation failed"; exit 1; }
        sudo systemctl enable docker
        sudo systemctl start docker
    else
        echo "Docker is already installed."
    fi
}

# Function to install Docker Compose
install_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        echo "Docker Compose is not installed. Installing Docker Compose..."
        sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/bin/docker-compose || { echo "Docker Compose download failed"; exit 1; }
        sudo chmod +x /usr/bin/docker-compose
    else
        echo "Docker Compose is already installed."
    fi
}

# Function to clone WhatsApp Proxy repository and run the proxy
run_proxy() {
    git clone https://github.com/WhatsApp/proxy.git || { echo "Failed to clone repository"; exit 1; }
    cd proxy || { echo "Failed to enter directory"; exit 1; }
    docker build proxy/ -t whatsapp_proxy:1.0 || { echo "Docker build failed"; exit 1; }
    docker run -it -p 5222:5222 whatsapp_proxy:1.0 || { echo "Failed to run Docker"; exit 1; }
    docker-compose -f /root/proxy/proxy/ops/docker-compose.yml up || { echo "Docker Compose failed"; exit 1; }
}

# Main script execution
update_system
install_docker
install_docker_compose
run_proxy