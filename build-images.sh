#!/bin/bash

###############################################################################
# HelaBooking Docker Images Build Script
# This script builds all Docker images for the HelaBooking microservices
###############################################################################

set -e

echo "========================================"
echo "Building HelaBooking Docker Images"
echo "========================================"

# Configure Docker to use Minikube's Docker daemon
echo "🔧 Configuring Docker to use Minikube's Docker daemon..."
eval $(minikube -p minikube docker-env)
echo "✅ Docker environment configured"

# Set Java 17 for the build
echo ""
echo "☕ Setting Java 17 for build..."
export JAVA_HOME=/usr/local/sdkman/candidates/java/17.0.17-ms
export PATH=$JAVA_HOME/bin:$PATH
echo "Java version: $(java -version 2>&1 | head -n 1)"
echo "✅ Java 17 configured"

# Build Maven project first
echo ""
echo "📦 Building Maven project..."
mvn clean package -DskipTests
echo "✅ Maven build completed"

# Array of services to build
SERVICES=(
    "user-service"
    "event-service"
    "booking-service"
    "ticketing-service"
    "notification-service"
    "audit-service"
)

# Build Docker images for each service
echo ""
echo "🐳 Building Docker images..."
for SERVICE in "${SERVICES[@]}"; do
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Building $SERVICE..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    docker build \
        -f ${SERVICE}/Dockerfile \
        -t helabooking/${SERVICE}:latest \
        -t helabooking/${SERVICE}:v1.0.0 \
        .
    
    echo "✅ $SERVICE image built successfully"
done

echo ""
echo "✅ All Docker images built successfully!"
echo ""
echo "📋 Built images:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker images | grep helabooking
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Next step: Run ./deploy.sh to deploy to Kubernetes"
echo ""
