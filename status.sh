#!/bin/bash

###############################################################################
# HelaBooking Quick Status Script
# This script shows the current status of all resources
###############################################################################

echo "========================================"
echo "HelaBooking Kubernetes Status"
echo "========================================"

# Check if cluster is running
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetes cluster is not accessible"
    echo "Run: minikube start"
    exit 1
fi

echo "✅ Cluster is running"
echo ""

# Get Minikube IP
MINIKUBE_IP=$(minikube ip 2>/dev/null)
if [ -n "$MINIKUBE_IP" ]; then
    echo "📍 Minikube IP: $MINIKUBE_IP"
else
    echo "⚠️  Could not get Minikube IP"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Pods Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl get pods -n helabooking 2>/dev/null || echo "No pods found in helabooking namespace"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Services"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl get svc -n helabooking 2>/dev/null || echo "No services found in helabooking namespace"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚪 Ingress"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl get ingress -n helabooking 2>/dev/null || echo "No ingress found in helabooking namespace"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💾 Persistent Volumes"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl get pvc -n helabooking 2>/dev/null || echo "No PVCs found in helabooking namespace"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Horizontal Pod Autoscalers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl get hpa -n helabooking 2>/dev/null || echo "No HPAs found in helabooking namespace"

if [ -n "$MINIKUBE_IP" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔗 Access URLs"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "User Service:        http://$MINIKUBE_IP:30081"
    echo "Event Service:       http://$MINIKUBE_IP:30082"
    echo "Booking Service:     http://$MINIKUBE_IP:30083"
    echo "RabbitMQ Management: http://$MINIKUBE_IP:31672"
    echo ""
    echo "Ingress (if configured):"
    echo "  http://helabooking.local/user/"
    echo "  http://helabooking.local/event/"
    echo "  http://helabooking.local/booking/"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Quick Commands"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Watch pods:           kubectl get pods -n helabooking -w"
echo "View logs:            kubectl logs -f deployment/user-service -n helabooking"
echo "Open dashboard:       minikube dashboard"
echo "Scale service:        kubectl scale deployment/user-service --replicas=3 -n helabooking"
echo "Restart service:      kubectl rollout restart deployment/user-service -n helabooking"
echo ""
