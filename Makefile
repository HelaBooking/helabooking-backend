.PHONY: help setup build deploy clean status test dashboard logs

# Default target
help:
	@echo "═══════════════════════════════════════════════════════════"
	@echo "HelaBooking Kubernetes Management"
	@echo "═══════════════════════════════════════════════════════════"
	@echo ""
	@echo "Available targets:"
	@echo ""
	@echo "  make setup       - Setup Minikube cluster with all addons"
	@echo "  make build       - Build all Docker images"
	@echo "  make deploy      - Deploy all services to Kubernetes"
	@echo "  make all         - Run setup, build, and deploy (full setup)"
	@echo ""
	@echo "  make status      - Show current deployment status"
	@echo "  make test        - Run API tests"
	@echo "  make dashboard   - Open Kubernetes dashboard"
	@echo ""
	@echo "  make logs-user   - View user service logs"
	@echo "  make logs-event  - View event service logs"
	@echo "  make logs-booking - View booking service logs"
	@echo "  make logs-rabbitmq - View RabbitMQ logs"
	@echo ""
	@echo "  make scale-up    - Scale all services to 3 replicas"
	@echo "  make scale-down  - Scale all services to 1 replica"
	@echo ""
	@echo "  make restart     - Restart all services"
	@echo "  make clean       - Remove all Kubernetes resources"
	@echo "  make reset       - Complete reset (stop and delete Minikube)"
	@echo ""
	@echo "═══════════════════════════════════════════════════════════"

# Full setup
all: setup build deploy

# Setup Minikube
setup:
	@echo "🚀 Setting up Minikube cluster..."
	@./setup-minikube.sh

# Build Docker images
build:
	@echo "🐳 Building Docker images..."
	@./build-images.sh

# Deploy to Kubernetes
deploy:
	@echo "📦 Deploying to Kubernetes..."
	@./deploy.sh

# Show status
status:
	@./status.sh

# Run tests
test:
	@./test-api.sh

# Open dashboard
dashboard:
	@echo "🎨 Opening Kubernetes dashboard..."
	@minikube dashboard

# View logs
logs-user:
	@kubectl logs -f deployment/user-service -n helabooking

logs-event:
	@kubectl logs -f deployment/event-service -n helabooking

logs-booking:
	@kubectl logs -f deployment/booking-service -n helabooking

logs-ticketing:
	@kubectl logs -f deployment/ticketing-service -n helabooking

logs-notification:
	@kubectl logs -f deployment/notification-service -n helabooking

logs-audit:
	@kubectl logs -f deployment/audit-service -n helabooking

logs-rabbitmq:
	@kubectl logs -f statefulset/rabbitmq -n helabooking

logs-all:
	@kubectl logs -f -l app -n helabooking --all-containers=true

# Scaling
scale-up:
	@echo "⬆️  Scaling services up to 3 replicas..."
	@kubectl scale deployment/user-service --replicas=3 -n helabooking
	@kubectl scale deployment/event-service --replicas=3 -n helabooking
	@kubectl scale deployment/booking-service --replicas=3 -n helabooking
	@kubectl scale deployment/ticketing-service --replicas=3 -n helabooking
	@kubectl scale deployment/notification-service --replicas=3 -n helabooking
	@kubectl scale deployment/audit-service --replicas=3 -n helabooking
	@echo "✅ Scaled up!"

scale-down:
	@echo "⬇️  Scaling services down to 1 replica..."
	@kubectl scale deployment/user-service --replicas=1 -n helabooking
	@kubectl scale deployment/event-service --replicas=1 -n helabooking
	@kubectl scale deployment/booking-service --replicas=1 -n helabooking
	@kubectl scale deployment/ticketing-service --replicas=1 -n helabooking
	@kubectl scale deployment/notification-service --replicas=1 -n helabooking
	@kubectl scale deployment/audit-service --replicas=1 -n helabooking
	@echo "✅ Scaled down!"

# Restart services
restart:
	@echo "🔄 Restarting all services..."
	@kubectl rollout restart deployment -n helabooking
	@echo "✅ Restarted!"

# Clean up
clean:
	@echo "🗑️  Cleaning up Kubernetes resources..."
	@./cleanup.sh

# Complete reset
reset:
	@echo "⚠️  Performing complete reset..."
	@make clean
	@minikube stop
	@minikube delete
	@echo "✅ Reset complete! Run 'make all' to redeploy."

# Port forwarding
forward-user:
	@echo "🔌 Forwarding user-service to localhost:8081..."
	@kubectl port-forward -n helabooking deployment/user-service 8081:8081

forward-event:
	@echo "🔌 Forwarding event-service to localhost:8082..."
	@kubectl port-forward -n helabooking deployment/event-service 8082:8082

forward-booking:
	@echo "🔌 Forwarding booking-service to localhost:8083..."
	@kubectl port-forward -n helabooking deployment/booking-service 8083:8083

forward-rabbitmq:
	@echo "🔌 Forwarding RabbitMQ management to localhost:15672..."
	@kubectl port-forward -n helabooking statefulset/rabbitmq 15672:15672

# Monitoring
watch-pods:
	@kubectl get pods -n helabooking -w

watch-all:
	@watch -n 2 kubectl get all -n helabooking

top-pods:
	@kubectl top pods -n helabooking

top-nodes:
	@kubectl top nodes

# Get shell access
shell-user:
	@kubectl exec -it deployment/user-service -n helabooking -- /bin/bash

shell-db-user:
	@kubectl exec -it statefulset/userdb -n helabooking -- /bin/bash

shell-rabbitmq:
	@kubectl exec -it statefulset/rabbitmq -n helabooking -- /bin/bash

# Database access
db-user:
	@echo "Connecting to userdb..."
	@kubectl port-forward -n helabooking statefulset/userdb 5432:5432 &
	@sleep 2
	@psql -h localhost -U postgres -d userdb

# Show URLs
urls:
	@echo "═══════════════════════════════════════════════════════════"
	@echo "Service URLs (Minikube IP: $$(minikube ip))"
	@echo "═══════════════════════════════════════════════════════════"
	@echo ""
	@echo "User Service:        http://$$(minikube ip):30081"
	@echo "Event Service:       http://$$(minikube ip):30082"
	@echo "Booking Service:     http://$$(minikube ip):30083"
	@echo "RabbitMQ Management: http://$$(minikube ip):31672"
	@echo ""
	@echo "Ingress URLs (add to /etc/hosts):"
	@echo "  http://helabooking.local/user/"
	@echo "  http://helabooking.local/event/"
	@echo "  http://helabooking.local/booking/"
	@echo ""
