#!/bin/bash

###############################################################################
# HelaBooking Kubernetes Verification Script
# This script verifies that all components are properly deployed and healthy
###############################################################################

set -e

NAMESPACE="helabooking"
TIMEOUT=300  # 5 minutes

echo "════════════════════════════════════════════════════════════"
echo "HelaBooking Kubernetes Deployment Verification"
echo "════════════════════════════════════════════════════════════"
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetes cluster is not accessible"
    echo "   Run: minikube start"
    exit 1
fi

echo "✅ Kubernetes cluster is accessible"

# Check if namespace exists
if ! kubectl get namespace $NAMESPACE &> /dev/null; then
    echo "❌ Namespace '$NAMESPACE' does not exist"
    echo "   Run: ./deploy.sh"
    exit 1
fi

echo "✅ Namespace '$NAMESPACE' exists"
echo ""

# Function to check pod readiness
check_pods_ready() {
    local label=$1
    local expected_count=$2
    local name=$3
    
    echo -n "Checking $name... "
    
    local ready_count=$(kubectl get pods -n $NAMESPACE -l $label -o json | \
        jq '[.items[] | select(.status.conditions[] | select(.type=="Ready" and .status=="True"))] | length')
    
    if [ "$ready_count" -ge "$expected_count" ]; then
        echo "✅ ($ready_count/$expected_count pods ready)"
        return 0
    else
        echo "⚠️  ($ready_count/$expected_count pods ready)"
        return 1
    fi
}

# Function to check service
check_service() {
    local service_name=$1
    
    echo -n "Checking service $service_name... "
    
    if kubectl get svc $service_name -n $NAMESPACE &> /dev/null; then
        echo "✅"
        return 0
    else
        echo "❌"
        return 1
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Checking Databases"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

DATABASES=(
    "app=userdb:1:UserDB"
    "app=eventdb:1:EventDB"
    "app=bookingdb:1:BookingDB"
    "app=ticketingdb:1:TicketingDB"
    "app=notificationdb:1:NotificationDB"
    "app=auditdb:1:AuditDB"
)

DB_ISSUES=0
for db in "${DATABASES[@]}"; do
    IFS=':' read -r label count name <<< "$db"
    if ! check_pods_ready "$label" "$count" "$name"; then
        ((DB_ISSUES++))
    fi
done

if [ $DB_ISSUES -eq 0 ]; then
    echo "✅ All databases are ready"
else
    echo "⚠️  $DB_ISSUES database(s) have issues"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🐰 Checking RabbitMQ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if check_pods_ready "app=rabbitmq" "1" "RabbitMQ"; then
    echo "✅ RabbitMQ is ready"
else
    echo "⚠️  RabbitMQ has issues"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Checking Microservices"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

SERVICES=(
    "app=user-service:2:User Service"
    "app=event-service:2:Event Service"
    "app=booking-service:2:Booking Service"
    "app=ticketing-service:2:Ticketing Service"
    "app=notification-service:2:Notification Service"
    "app=audit-service:2:Audit Service"
)

SERVICE_ISSUES=0
for svc in "${SERVICES[@]}"; do
    IFS=':' read -r label count name <<< "$svc"
    if ! check_pods_ready "$label" "$count" "$name"; then
        ((SERVICE_ISSUES++))
    fi
done

if [ $SERVICE_ISSUES -eq 0 ]; then
    echo "✅ All microservices are ready"
else
    echo "⚠️  $SERVICE_ISSUES microservice(s) have issues"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Checking Services"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

K8S_SERVICES=(
    "user-service"
    "event-service"
    "booking-service"
    "ticketing-service"
    "notification-service"
    "audit-service"
    "rabbitmq-service"
    "userdb-service"
    "eventdb-service"
    "bookingdb-service"
)

SVC_ISSUES=0
for svc_name in "${K8S_SERVICES[@]}"; do
    if ! check_service "$svc_name"; then
        ((SVC_ISSUES++))
    fi
done

if [ $SVC_ISSUES -eq 0 ]; then
    echo "✅ All Kubernetes services are created"
else
    echo "⚠️  $SVC_ISSUES service(s) missing"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 Checking ConfigMaps and Secrets"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -n "ConfigMap (helabooking-config)... "
if kubectl get configmap helabooking-config -n $NAMESPACE &> /dev/null; then
    echo "✅"
else
    echo "❌"
fi

echo -n "Secret (postgres-secret)... "
if kubectl get secret postgres-secret -n $NAMESPACE &> /dev/null; then
    echo "✅"
else
    echo "❌"
fi

echo -n "Secret (rabbitmq-secret)... "
if kubectl get secret rabbitmq-secret -n $NAMESPACE &> /dev/null; then
    echo "✅"
else
    echo "❌"
fi

echo -n "Secret (jwt-secret)... "
if kubectl get secret jwt-secret -n $NAMESPACE &> /dev/null; then
    echo "✅"
else
    echo "❌"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💾 Checking Persistent Volume Claims"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

PVC_COUNT=$(kubectl get pvc -n $NAMESPACE --no-headers 2>/dev/null | wc -l)
PVC_BOUND=$(kubectl get pvc -n $NAMESPACE --no-headers 2>/dev/null | grep -c "Bound" || echo 0)

echo "Total PVCs: $PVC_COUNT, Bound: $PVC_BOUND"

if [ $PVC_COUNT -eq $PVC_BOUND ] && [ $PVC_COUNT -gt 0 ]; then
    echo "✅ All PVCs are bound"
else
    echo "⚠️  Some PVCs are not bound"
    kubectl get pvc -n $NAMESPACE
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚪 Checking Ingress"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -n "Ingress (helabooking-ingress)... "
if kubectl get ingress helabooking-ingress -n $NAMESPACE &> /dev/null; then
    echo "✅"
else
    echo "❌"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Checking Horizontal Pod Autoscalers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

HPA_COUNT=$(kubectl get hpa -n $NAMESPACE --no-headers 2>/dev/null | wc -l)
echo "HPAs configured: $HPA_COUNT"

if [ $HPA_COUNT -ge 6 ]; then
    echo "✅ HPAs are configured"
else
    echo "⚠️  HPAs may not be fully configured"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Testing API Endpoints"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "unknown")

if [ "$MINIKUBE_IP" != "unknown" ]; then
    echo "Minikube IP: $MINIKUBE_IP"
    echo ""
    
    # Test User Service
    echo -n "User Service (http://$MINIKUBE_IP:30081)... "
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$MINIKUBE_IP:30081/actuator/health 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ (HTTP $HTTP_CODE)"
    else
        echo "⚠️  (HTTP $HTTP_CODE)"
    fi
    
    # Test Event Service
    echo -n "Event Service (http://$MINIKUBE_IP:30082)... "
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$MINIKUBE_IP:30082/actuator/health 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ (HTTP $HTTP_CODE)"
    else
        echo "⚠️  (HTTP $HTTP_CODE)"
    fi
    
    # Test Booking Service
    echo -n "Booking Service (http://$MINIKUBE_IP:30083)... "
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$MINIKUBE_IP:30083/actuator/health 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ (HTTP $HTTP_CODE)"
    else
        echo "⚠️  (HTTP $HTTP_CODE)"
    fi
    
    # Test RabbitMQ Management
    echo -n "RabbitMQ Management (http://$MINIKUBE_IP:31672)... "
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$MINIKUBE_IP:31672 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ (HTTP $HTTP_CODE)"
    else
        echo "⚠️  (HTTP $HTTP_CODE)"
    fi
else
    echo "⚠️  Could not get Minikube IP, skipping endpoint tests"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TOTAL_ISSUES=$((DB_ISSUES + SERVICE_ISSUES + SVC_ISSUES))

if [ $TOTAL_ISSUES -eq 0 ]; then
    echo "✅ All components are healthy and ready!"
    echo ""
    echo "🎉 HelaBooking is successfully deployed!"
    echo ""
    echo "📝 Access Information:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [ "$MINIKUBE_IP" != "unknown" ]; then
        echo "User Service:        http://$MINIKUBE_IP:30081"
        echo "Event Service:       http://$MINIKUBE_IP:30082"
        echo "Booking Service:     http://$MINIKUBE_IP:30083"
        echo "RabbitMQ Management: http://$MINIKUBE_IP:31672"
        echo ""
        echo "RabbitMQ Credentials: guest / guest"
    fi
    echo ""
    echo "📝 Next steps:"
    echo "  - Run './test-api.sh' to test the APIs"
    echo "  - Run 'make dashboard' to open Kubernetes dashboard"
    echo "  - Run 'make status' to check status anytime"
    exit 0
else
    echo "⚠️  Found $TOTAL_ISSUES issue(s) - some components may not be ready yet"
    echo ""
    echo "📝 Troubleshooting:"
    echo "  - Check pod status: kubectl get pods -n $NAMESPACE"
    echo "  - View pod logs: kubectl logs -f <pod-name> -n $NAMESPACE"
    echo "  - Describe pod: kubectl describe pod <pod-name> -n $NAMESPACE"
    echo "  - View events: kubectl get events -n $NAMESPACE"
    echo ""
    echo "⏳ Note: Services may still be starting up. Wait a few minutes and run this script again."
    exit 1
fi
