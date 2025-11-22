#!/bin/bash

###############################################################################
# HelaBooking Minikube Setup Script
# This script sets up Minikube with all required addons and configurations
###############################################################################

set -e

echo "========================================"
echo "HelaBooking Minikube Setup"
echo "========================================"

# Check if minikube is installed
if ! command -v minikube &> /dev/null; then
    echo "❌ Minikube is not installed. Please install it first."
    echo "Visit: https://minikube.sigs.k8s.io/docs/start/"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install it first."
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "✅ Prerequisites checked"

# Start Minikube with resource configuration
echo ""
echo "🚀 Starting Minikube cluster..."
minikube start \
    --cpus=4 \
    --memory=8192 \
    --disk-size=20g \
    --driver=docker \
    --kubernetes-version=v1.28.0

echo "✅ Minikube cluster started"

# Enable required addons
echo ""
echo "🔧 Enabling Minikube addons..."
minikube addons enable ingress
minikube addons enable metrics-server
minikube addons enable dashboard
minikube addons enable storage-provisioner
minikube addons enable default-storageclass

echo "✅ Addons enabled"

# Configure kubectl context
echo ""
echo "⚙️  Configuring kubectl context..."
kubectl config use-context minikube

echo "✅ kubectl context configured"

# Display cluster info
echo ""
echo "📊 Cluster Information:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl cluster-info
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Display node info
echo ""
echo "🖥️  Node Information:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl get nodes
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Get Minikube IP
MINIKUBE_IP=$(minikube ip)
echo ""
echo "📍 Minikube IP: $MINIKUBE_IP"

# Add entry to /etc/hosts (requires sudo)
echo ""
echo "🔐 Adding helabooking.local to /etc/hosts..."
if grep -q "helabooking.local" /etc/hosts; then
    echo "⚠️  Entry already exists in /etc/hosts"
    sudo sed -i "/helabooking.local/d" /etc/hosts
fi
echo "$MINIKUBE_IP helabooking.local" | sudo tee -a /etc/hosts > /dev/null
echo "✅ Added helabooking.local to /etc/hosts"

echo ""
echo "✅ Minikube setup completed successfully!"
echo ""
echo "📝 Next steps:"
echo "  1. Run ./build-images.sh to build Docker images"
echo "  2. Run ./deploy.sh to deploy the application"
echo "  3. Run 'minikube dashboard' to open Kubernetes dashboard"
echo ""
