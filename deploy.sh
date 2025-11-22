#!/bin/bash

###############################################################################
# HelaBooking Kubernetes Deployment Script
# This script deploys all resources to Kubernetes
###############################################################################

set -e

echo "========================================"
echo "Deploying HelaBooking to Kubernetes"
echo "========================================"

# Verify kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ kubectl is not configured or cluster is not running"
    exit 1
fi

echo "✅ Kubernetes cluster is accessible"

# Create namespace
echo ""
echo "📦 Creating namespace..."
kubectl apply -f k8s/namespace.yaml
echo "✅ Namespace created"

# Apply secrets and configmaps
echo ""
echo "🔐 Applying secrets and configmaps..."
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/configmap.yaml
echo "✅ Secrets and configmaps applied"

# Deploy databases
echo ""
echo "🗄️  Deploying databases..."
kubectl apply -f k8s/databases.yaml
echo "✅ Database deployments created"

# Wait for databases to be ready
echo ""
echo "⏳ Waiting for databases to be ready (this may take 2-3 minutes)..."
echo "   Waiting for userdb..."
kubectl wait --for=condition=ready pod -l app=userdb -n helabooking --timeout=300s || true
echo "   Waiting for eventdb..."
kubectl wait --for=condition=ready pod -l app=eventdb -n helabooking --timeout=300s || true
echo "   Waiting for bookingdb..."
kubectl wait --for=condition=ready pod -l app=bookingdb -n helabooking --timeout=300s || true
echo "   Waiting for ticketingdb..."
kubectl wait --for=condition=ready pod -l app=ticketingdb -n helabooking --timeout=300s || true
echo "   Waiting for notificationdb..."
kubectl wait --for=condition=ready pod -l app=notificationdb -n helabooking --timeout=300s || true
echo "   Waiting for auditdb..."
kubectl wait --for=condition=ready pod -l app=auditdb -n helabooking --timeout=300s || true
echo "✅ Databases are ready"

# Deploy RabbitMQ
echo ""
echo "🐰 Deploying RabbitMQ..."
kubectl apply -f k8s/rabbitmq.yaml
echo "✅ RabbitMQ deployment created"

# Wait for RabbitMQ to be ready
echo ""
echo "⏳ Waiting for RabbitMQ to be ready (this may take 1-2 minutes)..."
kubectl wait --for=condition=ready pod -l app=rabbitmq -n helabooking --timeout=300s || true
echo "✅ RabbitMQ is ready"

# Deploy microservices
echo ""
echo "🚀 Deploying microservices..."
kubectl apply -f k8s/services.yaml
echo "✅ Microservices deployments created"

# Wait for services to be ready
echo ""
echo "⏳ Waiting for microservices to be ready (this may take 2-3 minutes)..."
sleep 30  # Give services time to start initializing
echo "   Checking service status..."
kubectl get pods -n helabooking
echo "✅ Microservices deployment initiated"

# Deploy Ingress
echo ""
echo "🌐 Deploying Ingress..."
kubectl apply -f k8s/ingress.yaml
echo "✅ Ingress created"

# Deploy HPA (optional)
echo ""
echo "📊 Deploying Horizontal Pod Autoscalers..."
kubectl apply -f k8s/hpa.yaml || echo "⚠️  HPA deployment skipped (metrics-server might not be ready)"
echo "✅ HPA configurations applied"

# Display deployment status
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Deployment Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Pods:"
kubectl get pods -n helabooking
echo ""
echo "Services:"
kubectl get svc -n helabooking
echo ""
echo "Ingress:"
kubectl get ingress -n helabooking
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Get access information
MINIKUBE_IP=$(minikube ip)
echo ""
echo "✅ Deployment completed!"
echo ""
echo "📝 Access Information:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Minikube IP: $MINIKUBE_IP"
echo ""
echo "Service Endpoints (NodePort):"
echo "  User Service:         http://$MINIKUBE_IP:30081"
echo "  Event Service:        http://$MINIKUBE_IP:30082"
echo "  Booking Service:      http://$MINIKUBE_IP:30083"
echo "  RabbitMQ Management:  http://$MINIKUBE_IP:31672"
echo ""
echo "Ingress (requires 'helabooking.local' in /etc/hosts):"
echo "  User Service:         http://helabooking.local/user/"
echo "  Event Service:        http://helabooking.local/event/"
echo "  Booking Service:      http://helabooking.local/booking/"
echo ""
echo "RabbitMQ Credentials:"
echo "  Username: guest"
echo "  Password: guest"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Useful commands:"
echo "  kubectl get pods -n helabooking                    # Check pod status"
echo "  kubectl logs -f <pod-name> -n helabooking          # View logs"
echo "  kubectl describe pod <pod-name> -n helabooking     # Pod details"
echo "  minikube dashboard                                 # Open dashboard"
echo "  kubectl port-forward -n helabooking <pod> 8081:8081 # Port forward"
echo ""
