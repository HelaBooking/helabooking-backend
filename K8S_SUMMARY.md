# Kubernetes Deployment Summary

## 📦 What Was Created

### Kubernetes Manifests (k8s/)

1. **namespace.yaml** - Defines the `helabooking` namespace
2. **secrets.yaml** - Contains credentials for PostgreSQL, RabbitMQ, and JWT
3. **configmap.yaml** - Configuration values for services
4. **databases.yaml** - 6 PostgreSQL StatefulSets with persistent volumes
5. **rabbitmq.yaml** - RabbitMQ StatefulSet with management UI
6. **services.yaml** - 6 microservice Deployments and Services
7. **ingress.yaml** - NGINX Ingress for external routing
8. **hpa.yaml** - Horizontal Pod Autoscalers for all services
9. **kustomization.yaml** - Kustomize configuration

### Scripts

1. **setup-minikube.sh** - Sets up Minikube cluster with all addons
2. **build-images.sh** - Builds Docker images for all services
3. **deploy.sh** - Deploys all resources to Kubernetes
4. **cleanup.sh** - Removes all Kubernetes resources
5. **status.sh** - Shows current deployment status
6. **test-api.sh** - Runs API tests against deployed services

### Additional Files

1. **Makefile** - Convenient commands for all operations
2. **KUBERNETES_GUIDE.md** - Complete deployment documentation
3. **k8s/README.md** - Quick reference guide

## 🚀 Quick Start

### Option 1: Using Makefile (Easiest)

```bash
make all              # Full setup: Minikube + Build + Deploy
make status           # Check deployment status
make test             # Run tests
```

### Option 2: Using Scripts

```bash
./setup-minikube.sh   # Setup Minikube
./build-images.sh     # Build images
./deploy.sh           # Deploy to K8s
./status.sh           # Check status
./test-api.sh         # Test APIs
```

### Option 3: Manual kubectl

```bash
# Setup Minikube
minikube start --cpus=4 --memory=8192

# Build images
eval $(minikube docker-env)
mvn clean package -DskipTests
docker build -t helabooking/user-service:latest -f user-service/Dockerfile .
# ... repeat for other services

# Deploy
kubectl apply -f k8s/
```

## 📊 Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│               Kubernetes Cluster                    │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │         NGINX Ingress Controller             │  │
│  │         helabooking.local                    │  │
│  └────────┬────────────┬────────────────────────┘  │
│           │            │                           │
│  ┌────────▼───┐  ┌────▼─────┐  ┌──────────┐      │
│  │User Service│  │Event Svc │  │Booking   │      │
│  │(2 replicas)│  │(2 replicas│  │Service   │      │
│  └────────┬───┘  └────┬─────┘  │(2 replicas│      │
│           │           │         └──────────┘      │
│  ┌────────▼───┐  ┌───▼──────┐  ┌──────────┐      │
│  │  UserDB    │  │ EventDB  │  │BookingDB │      │
│  │(StatefulSet│  │(StatefulSet│(StatefulSet│      │
│  └────────────┘  └──────────┘  └──────────┘      │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │        RabbitMQ (StatefulSet)                │  │
│  └──┬────────────┬────────────┬────────────────┘  │
│     │            │            │                   │
│  ┌──▼───────┐ ┌─▼──────┐  ┌──▼────────┐          │
│  │Ticketing │ │Notif   │  │Audit Svc  │          │
│  │Service   │ │Service │  │(2 replicas│          │
│  │(2 replicas│ │(2 replicas └───┬──────┘          │
│  └──┬───────┘ └─┬──────┘      │                  │
│     │           │              │                  │
│  ┌──▼────────┐ ┌▼──────┐  ┌───▼──────┐           │
│  │TicketingDB│ │NotifDB│  │ AuditDB  │           │
│  └───────────┘ └───────┘  └──────────┘           │
└─────────────────────────────────────────────────────┘
```

## 🎯 Key Features

### High Availability
- 2 replicas per service by default
- Auto-scaling (2-5 replicas based on CPU/Memory)
- Health checks (liveness & readiness probes)

### Storage
- Persistent volumes for all databases
- 1GB storage per database
- 2GB for RabbitMQ

### Networking
- Internal ClusterIP services for service-to-service communication
- NodePort services for external access (30081-30083)
- Ingress for domain-based routing

### Configuration Management
- ConfigMaps for non-sensitive configuration
- Secrets for credentials (PostgreSQL, RabbitMQ, JWT)
- Environment variable injection

### Resource Management
- CPU & Memory requests/limits defined
- HPA for automatic scaling
- Resource quotas can be added

## 🔗 Access Points

### NodePort (Direct Access)

Get Minikube IP:
```bash
MINIKUBE_IP=$(minikube ip)
```

**Service URLs:**
- User Service: `http://$MINIKUBE_IP:30081`
- Event Service: `http://$MINIKUBE_IP:30082`
- Booking Service: `http://$MINIKUBE_IP:30083`
- RabbitMQ UI: `http://$MINIKUBE_IP:31672`

### Ingress (Domain-based)

Add to `/etc/hosts`:
```bash
echo "$(minikube ip) helabooking.local" | sudo tee -a /etc/hosts
```

**Access URLs:**
- User: `http://helabooking.local/user/`
- Event: `http://helabooking.local/event/`
- Booking: `http://helabooking.local/booking/`

## 📝 Common Operations

### Check Status
```bash
make status
# or
kubectl get all -n helabooking
```

### View Logs
```bash
make logs-user
# or
kubectl logs -f deployment/user-service -n helabooking
```

### Scale Services
```bash
make scale-up    # Scale to 3 replicas
make scale-down  # Scale to 1 replica
# or
kubectl scale deployment/user-service --replicas=3 -n helabooking
```

### Restart Services
```bash
make restart
# or
kubectl rollout restart deployment/user-service -n helabooking
```

### Monitor Resources
```bash
kubectl top pods -n helabooking
kubectl top nodes
```

### Access Dashboard
```bash
make dashboard
# or
minikube dashboard
```

## 🧪 Testing

### Automated Tests
```bash
./test-api.sh
# or
make test
```

### Manual Testing
```bash
MINIKUBE_IP=$(minikube ip)

# Register user
curl -X POST http://$MINIKUBE_IP:30081/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","password":"pass123"}'

# Login
curl -X POST http://$MINIKUBE_IP:30081/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"pass123"}'

# Create event
curl -X POST http://$MINIKUBE_IP:30082/api/events \
  -H "Content-Type: application/json" \
  -d '{"name":"Concert","location":"Stadium","eventDate":"2024-12-31T20:00:00","capacity":100}'

# Create booking
curl -X POST http://$MINIKUBE_IP:30083/api/bookings \
  -H "Content-Type: application/json" \
  -d '{"userId":1,"eventId":1,"numberOfTickets":2}'
```

## 🔧 Troubleshooting

### Pods Not Starting
```bash
kubectl get pods -n helabooking
kubectl describe pod <pod-name> -n helabooking
kubectl logs <pod-name> -n helabooking
```

### Service Issues
```bash
kubectl get svc -n helabooking
kubectl describe svc user-service -n helabooking
kubectl get endpoints -n helabooking
```

### Resource Issues
```bash
kubectl top nodes
kubectl top pods -n helabooking
```

### Complete Reset
```bash
make reset
# or
./cleanup.sh
minikube delete
minikube start
```

## 🗑️ Cleanup

### Remove Deployment
```bash
make clean
# or
./cleanup.sh
```

### Complete Reset
```bash
make reset
# or
minikube stop
minikube delete
```

## 📚 Documentation

- **[KUBERNETES_GUIDE.md](KUBERNETES_GUIDE.md)** - Complete deployment guide with detailed instructions
- **[k8s/README.md](k8s/README.md)** - Quick reference for Kubernetes deployment
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture documentation
- **[README.md](README.md)** - Main project README

## 🎓 Makefile Commands

```bash
make help           # Show all commands
make all            # Full setup
make setup          # Setup Minikube
make build          # Build images
make deploy         # Deploy to K8s
make status         # Show status
make test           # Run tests
make dashboard      # Open dashboard
make logs-user      # User service logs
make logs-event     # Event service logs
make logs-booking   # Booking service logs
make logs-rabbitmq  # RabbitMQ logs
make scale-up       # Scale to 3 replicas
make scale-down     # Scale to 1 replica
make restart        # Restart services
make clean          # Clean up
make reset          # Complete reset
```

## 💡 Tips

1. **Always use Makefile** - It simplifies everything
2. **Check status frequently** - `make status` shows everything at a glance
3. **Monitor logs** - Use `make logs-<service>` to debug issues
4. **Scale as needed** - Use `make scale-up` for load testing
5. **HPA is active** - Services will auto-scale based on load

## 🚀 Production Considerations

For production deployment:

1. **Use managed Kubernetes** (EKS, GKE, AKS)
2. **External databases** (RDS, Cloud SQL)
3. **Managed message broker** (Amazon MQ, Cloud Pub/Sub)
4. **Update secrets** - Change all default credentials
5. **Enable TLS/SSL** for Ingress
6. **Add monitoring** (Prometheus, Grafana)
7. **Centralized logging** (ELK stack)
8. **CI/CD pipeline** (GitHub Actions, ArgoCD)
9. **Service mesh** (Istio, Linkerd)
10. **Backup strategy** for persistent data

## ✅ Checklist

- [x] Kubernetes manifests created
- [x] StatefulSets for databases
- [x] StatefulSet for RabbitMQ
- [x] Deployments for microservices
- [x] Services for networking
- [x] Ingress for external access
- [x] ConfigMaps and Secrets
- [x] HPA for auto-scaling
- [x] Setup scripts
- [x] Build scripts
- [x] Deploy scripts
- [x] Cleanup scripts
- [x] Status check script
- [x] API test script
- [x] Makefile for convenience
- [x] Comprehensive documentation
- [x] Resource limits defined
- [x] Health checks configured
- [x] Persistent storage configured

## 🎉 Ready to Deploy!

Run `make all` and your complete microservices platform will be up and running in Kubernetes! 🚀

For questions or issues, refer to:
- [KUBERNETES_GUIDE.md](KUBERNETES_GUIDE.md) for detailed instructions
- [k8s/README.md](k8s/README.md) for quick reference
- Check pod logs: `kubectl logs -f <pod-name> -n helabooking`
- View events: `kubectl get events -n helabooking`
