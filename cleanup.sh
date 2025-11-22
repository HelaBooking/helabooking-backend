#!/bin/bash

###############################################################################
# HelaBooking Kubernetes Cleanup Script
# This script removes all Kubernetes resources
###############################################################################

set -e

echo "========================================"
echo "Cleaning up HelaBooking Deployment"
echo "========================================"

# Delete all resources in the namespace
echo "🗑️  Deleting all resources in helabooking namespace..."
kubectl delete all --all -n helabooking

echo ""
echo "🗑️  Deleting HPA..."
kubectl delete -f k8s/hpa.yaml --ignore-not-found=true

echo ""
echo "🗑️  Deleting Ingress..."
kubectl delete -f k8s/ingress.yaml --ignore-not-found=true

echo ""
echo "🗑️  Deleting services..."
kubectl delete -f k8s/services.yaml --ignore-not-found=true

echo ""
echo "🗑️  Deleting RabbitMQ..."
kubectl delete -f k8s/rabbitmq.yaml --ignore-not-found=true

echo ""
echo "🗑️  Deleting databases..."
kubectl delete -f k8s/databases.yaml --ignore-not-found=true

echo ""
echo "🗑️  Deleting ConfigMaps and Secrets..."
kubectl delete -f k8s/configmap.yaml --ignore-not-found=true
kubectl delete -f k8s/secrets.yaml --ignore-not-found=true

echo ""
echo "🗑️  Deleting PVCs..."
kubectl delete pvc --all -n helabooking

echo ""
echo "🗑️  Deleting namespace..."
kubectl delete -f k8s/namespace.yaml --ignore-not-found=true

echo ""
echo "✅ Cleanup completed!"
echo ""
echo "📝 To completely reset:"
echo "  minikube stop      # Stop the cluster"
echo "  minikube delete    # Delete the cluster"
echo ""
