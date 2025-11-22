# HelaBooking Kubernetes Deployment

Quick reference guide for deploying HelaBooking on Kubernetes with Minikube.

## 🚀 Quick Start (3 Commands)

```bash
./setup-minikube.sh   # Setup Minikube cluster
./build-images.sh     # Build Docker images
./deploy.sh           # Deploy to Kubernetes
```

## 📦 What Gets Deployed

- **6 Microservices** (2 replicas each with auto-scaling)
  - User Service (Port 8081)
  - Event Service (Port 8082)
  - Booking Service (Port 8083)
  - Ticketing Service (Port 8084)
  - Notification Service (Port 8085)
  - Audit Service (Port 8086)

- **6 PostgreSQL Databases** (StatefulSets with persistent storage)
  - One database per service
  - 1GB storage per database

- **RabbitMQ** (StatefulSet with management UI)
  - Message broker for async communication
  - Management UI on port 31672

- **Kubernetes Resources**
  - Namespace: `helabooking`
  - ConfigMaps & Secrets for configuration
  - Services for internal communication
  - Ingress for external routing
  - HPA for auto-scaling (CPU/Memory based)

## 📋 Prerequisites

- Docker (v20.10+)
- Minikube (v1.30+)
- kubectl (v1.28+)
- Maven 3.8+ & Java 17
- 4 CPU cores, 8GB RAM, 20GB disk

## 🎯 Using Makefile (Recommended)

```bash
# Show all available commands
make help

# Full setup
make all              # Setup + Build + Deploy

# Individual steps
make setup            # Setup Minikube
make build            # Build images
make deploy           # Deploy to K8s

# Management
make status           # Show deployment status
make test             # Run API tests
make dashboard        # Open K8s dashboard

# Logs
make logs-user        # User service logs
make logs-event       # Event service logs
make logs-booking     # Booking service logs
make logs-rabbitmq    # RabbitMQ logs

# Scaling
make scale-up         # Scale to 3 replicas
make scale-down       # Scale to 1 replica

# Cleanup
make clean            # Remove all resources
make reset            # Complete reset
```

## 🌐 Accessing Services

### NodePort (Direct Access)

```bash
# Get Minikube IP
MINIKUBE_IP=$(minikube ip)

# Service URLs
User Service:        http://$MINIKUBE_IP:30081
Event Service:       http://$MINIKUBE_IP:30082
Booking Service:     http://$MINIKUBE_IP:30083
RabbitMQ Management: http://$MINIKUBE_IP:31672
```

### Ingress (Domain-based Access)

Add to `/etc/hosts`:
```bash
echo "$(minikube ip) helabooking.local" | sudo tee -a /etc/hosts
```

Access via:
```
http://helabooking.local/user/
http://helabooking.local/event/
http://helabooking.local/booking/
```

## 🧪 Testing

```bash
# Run automated tests
./test-api.sh

# Or use Makefile
make test
```

## 📊 Monitoring

```bash
# Check status
./status.sh
# or
make status

# Watch pods
kubectl get pods -n helabooking -w
# or
make watch-pods

# View logs
kubectl logs -f deployment/user-service -n helabooking
# or
make logs-user

# Resource usage
kubectl top pods -n helabooking
# or
make top-pods

# Open dashboard
minikube dashboard
# or
make dashboard
```

## 🔧 Common Tasks

### Scale Services

```bash
# Scale specific service
kubectl scale deployment/user-service --replicas=3 -n helabooking

# Scale all services
make scale-up    # to 3 replicas
make scale-down  # to 1 replica
```

### Restart Services

```bash
# Restart specific service
kubectl rollout restart deployment/user-service -n helabooking

# Restart all services
make restart
```

### View Logs

```bash
# Stream logs
kubectl logs -f deployment/user-service -n helabooking

# Last 100 lines
kubectl logs --tail=100 deployment/user-service -n helabooking

# All pods of a service
kubectl logs -l app=user-service -n helabooking --all-containers=true
```

### Access Pods

```bash
# Get shell access
kubectl exec -it deployment/user-service -n helabooking -- /bin/bash

# Run command
kubectl exec deployment/user-service -n helabooking -- env
```

### Port Forwarding

```bash
# Forward service port
kubectl port-forward deployment/user-service 8081:8081 -n helabooking

# Forward database
kubectl port-forward statefulset/userdb 5432:5432 -n helabooking

# Or use Makefile
make forward-user
make forward-rabbitmq
```

## 🗑️ Cleanup

```bash
# Remove all Kubernetes resources
./cleanup.sh
# or
make clean

# Complete reset (including Minikube)
make reset
```

## 📚 Documentation

For detailed documentation, see:
- **[KUBERNETES_GUIDE.md](KUBERNETES_GUIDE.md)** - Complete deployment guide
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture
- **[README.md](README.md)** - Main project README

## 🐛 Troubleshooting

### Pods not starting?
```bash
kubectl describe pod <pod-name> -n helabooking
kubectl logs <pod-name> -n helabooking
```

### Out of resources?
```bash
# Increase Minikube resources
minikube stop
minikube delete
minikube start --cpus=6 --memory=12288
```

### Need to rebuild?
```bash
make clean
make all
```

### Complete reset?
```bash
make reset
make all
```

## 📝 File Structure

```
.
├── k8s/                          # Kubernetes manifests
│   ├── namespace.yaml            # Namespace definition
│   ├── secrets.yaml              # Secrets (credentials)
│   ├── configmap.yaml            # ConfigMap (configuration)
│   ├── databases.yaml            # PostgreSQL StatefulSets
│   ├── rabbitmq.yaml             # RabbitMQ StatefulSet
│   ├── services.yaml             # Microservice Deployments
│   ├── ingress.yaml              # Ingress configuration
│   ├── hpa.yaml                  # Horizontal Pod Autoscalers
│   └── kustomization.yaml        # Kustomize configuration
├── setup-minikube.sh             # Minikube setup script
├── build-images.sh               # Docker image build script
├── deploy.sh                     # Kubernetes deployment script
├── cleanup.sh                    # Resource cleanup script
├── status.sh                     # Status check script
├── test-api.sh                   # API testing script
├── Makefile                      # Make commands for convenience
└── KUBERNETES_GUIDE.md           # Detailed guide
```

## 🔗 Useful Links

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

## 💡 Tips

1. **Use Makefile** - Simplifies all operations
2. **Check status frequently** - `make status` shows everything
3. **Monitor logs** - Use `make logs-<service>` to debug
4. **Resource limits** - Adjust based on your system
5. **HPA** - Automatically scales based on load

## 🆘 Getting Help

```bash
# Show available commands
make help

# Check cluster status
make status

# View documentation
cat KUBERNETES_GUIDE.md
```

---

**Ready to deploy?** Run `make all` and you're set! 🚀
