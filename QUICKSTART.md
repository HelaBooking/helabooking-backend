# 🚀 Quick Start Guide - HelaBooking on Kubernetes

## One-Line Deploy (After Prerequisites)

```bash
make all && ./verify-deployment.sh
```

## Prerequisites Check

```bash
# Check installations
docker --version        # Should be 20.10+
minikube version       # Should be 1.30+
kubectl version        # Should be 1.28+
java -version          # Should be 17+
mvn -version           # Should be 3.8+
```

## 3-Step Manual Deploy

### Step 1: Setup Minikube
```bash
./setup-minikube.sh
```
⏱️ Takes ~2 minutes

### Step 2: Build Images
```bash
./build-images.sh
```
⏱️ Takes ~5-10 minutes (first time)

### Step 3: Deploy to Kubernetes
```bash
./deploy.sh
```
⏱️ Takes ~5-8 minutes

### Step 4: Verify
```bash
./verify-deployment.sh
```

## Expected Results

After deployment, you should see:
- ✅ 6 database pods running
- ✅ 1 RabbitMQ pod running
- ✅ 12+ microservice pods running (2 per service)
- ✅ All services accessible via NodePort

## Access Your Services

```bash
# Get Minikube IP
export MINIKUBE_IP=$(minikube ip)

# Test User Service
curl http://$MINIKUBE_IP:30081/actuator/health

# Test Event Service  
curl http://$MINIKUBE_IP:30082/actuator/health

# Test Booking Service
curl http://$MINIKUBE_IP:30083/actuator/health

# Open RabbitMQ Management
echo "http://$MINIKUBE_IP:31672"  # guest/guest
```

## Quick Commands

```bash
make status           # Check everything
make logs-user        # View user service logs
make test             # Run API tests
make dashboard        # Open Kubernetes dashboard
make scale-up         # Scale to 3 replicas
make clean            # Remove everything
```

## Troubleshooting

### Pods not starting?
```bash
kubectl get pods -n helabooking
kubectl describe pod <pod-name> -n helabooking
kubectl logs <pod-name> -n helabooking
```

### Need more resources?
```bash
minikube stop
minikube delete
minikube start --cpus=6 --memory=12288
```

### Start fresh?
```bash
make reset
make all
```

## Full Documentation

- **Quick Reference**: [k8s/README.md](k8s/README.md)
- **Complete Guide**: [KUBERNETES_GUIDE.md](KUBERNETES_GUIDE.md)
- **Summary**: [K8S_SUMMARY.md](K8S_SUMMARY.md)
- **Main README**: [README.md](README.md)

## Test APIs

```bash
# Run automated tests
./test-api.sh

# Or manually
MINIKUBE_IP=$(minikube ip)

# Register user
curl -X POST http://$MINIKUBE_IP:30081/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","password":"pass123"}'

# Create event
curl -X POST http://$MINIKUBE_IP:30082/api/events \
  -H "Content-Type: application/json" \
  -d '{"name":"Concert","location":"Stadium","eventDate":"2024-12-31T20:00:00","capacity":100}'

# Create booking
curl -X POST http://$MINIKUBE_IP:30083/api/bookings \
  -H "Content-Type: application/json" \
  -d '{"userId":1,"eventId":1,"numberOfTickets":2}'
```

## What's Running?

After successful deployment:

```
Namespace: helabooking
├── Databases (6 StatefulSets)
│   ├── UserDB (1 pod)
│   ├── EventDB (1 pod)
│   ├── BookingDB (1 pod)
│   ├── TicketingDB (1 pod)
│   ├── NotificationDB (1 pod)
│   └── AuditDB (1 pod)
├── Message Broker
│   └── RabbitMQ (1 pod)
└── Microservices (6 Deployments)
    ├── User Service (2 pods)
    ├── Event Service (2 pods)
    ├── Booking Service (2 pods)
    ├── Ticketing Service (2 pods)
    ├── Notification Service (2 pods)
    └── Audit Service (2 pods)

Total: 19+ pods
```

## Need Help?

```bash
make help             # Show all commands
./verify-deployment.sh # Verify everything is working
kubectl get pods -n helabooking -w  # Watch pods
```

---

**Ready?** Just run: `make all` 🚀
