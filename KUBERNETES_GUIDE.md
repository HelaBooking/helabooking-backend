# HelaBooking Kubernetes Deployment Guide

Complete guide for deploying HelaBooking microservices on Kubernetes using Minikube.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Configuration](#configuration)
- [Accessing Services](#accessing-services)
- [Monitoring and Management](#monitoring-and-management)
- [Troubleshooting](#troubleshooting)
- [Production Considerations](#production-considerations)

## Overview

This deployment uses Kubernetes to orchestrate the HelaBooking microservices platform with:

- **6 Microservices**: User, Event, Booking, Ticketing, Notification, and Audit services
- **6 PostgreSQL Databases**: One database per service (database-per-service pattern)
- **RabbitMQ**: Message broker for asynchronous communication
- **Kubernetes Features**: 
  - StatefulSets for databases and RabbitMQ
  - Deployments for microservices
  - Services for internal communication
  - Ingress for external access
  - ConfigMaps and Secrets for configuration
  - Horizontal Pod Autoscaling (HPA)
  - Persistent Volumes for data storage

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                        │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Ingress Controller (NGINX)               │  │
│  │              helabooking.local                        │  │
│  └────────┬────────────┬────────────┬───────────────────┘  │
│           │            │            │                       │
│  ┌────────▼───┐  ┌────▼─────┐  ┌──▼────────┐             │
│  │User Service│  │Event Svc │  │Booking Svc│             │
│  │ (2 pods)   │  │(2 pods)  │  │ (2 pods)  │             │
│  └────────┬───┘  └────┬─────┘  └──┬────────┘             │
│           │           │            │                       │
│  ┌────────▼───┐  ┌───▼──────┐  ┌─▼─────────┐             │
│  │  UserDB    │  │ EventDB  │  │BookingDB  │             │
│  │(StatefulSet│  │(StatefulSet│(StatefulSet│             │
│  └────────────┘  └──────────┘  └───────────┘             │
│                                                            │
│  ┌──────────────────────────────────────────────────┐    │
│  │              RabbitMQ (StatefulSet)              │    │
│  │         Message Broker & Event Bus               │    │
│  └──┬────────────────┬────────────────┬─────────────┘    │
│     │                │                │                   │
│  ┌──▼───────┐  ┌────▼─────┐  ┌──────▼────┐              │
│  │Ticketing │  │Notification│  │Audit Svc  │              │
│  │Service   │  │Service     │  │(2 pods)   │              │
│  │(2 pods)  │  │(2 pods)    │  └──┬────────┘              │
│  └──┬───────┘  └────┬───────┘     │                      │
│     │               │              │                      │
│  ┌──▼────────┐  ┌──▼──────┐  ┌───▼──────┐               │
│  │TicketingDB│  │NotifDB  │  │ AuditDB  │               │
│  └───────────┘  └─────────┘  └──────────┘               │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Prerequisites

### Required Software

1. **Docker** (v20.10+)
   ```bash
   docker --version
   ```

2. **Minikube** (v1.30+)
   ```bash
   # Linux
   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
   sudo install minikube-linux-amd64 /usr/local/bin/minikube
   
   # macOS
   brew install minikube
   ```

3. **kubectl** (v1.28+)
   ```bash
   # Linux
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
   
   # macOS
   brew install kubectl
   ```

4. **Maven** (v3.8+) and **Java 17**
   ```bash
   java -version
   mvn -version
   ```

### System Requirements

- **CPU**: 4 cores minimum (6-8 recommended)
- **RAM**: 8 GB minimum (12-16 GB recommended)
- **Disk**: 20 GB free space

## Quick Start

### One-Command Setup (Recommended)

```bash
# 1. Setup Minikube cluster with all addons
./setup-minikube.sh

# 2. Build all Docker images
./build-images.sh

# 3. Deploy to Kubernetes
./deploy.sh
```

### Verify Deployment

```bash
# Check all pods are running
kubectl get pods -n helabooking

# Check services
kubectl get svc -n helabooking

# Watch pods start up
kubectl get pods -n helabooking -w
```

### Quick Test

```bash
# Get Minikube IP
MINIKUBE_IP=$(minikube ip)

# Register a user
curl -X POST http://$MINIKUBE_IP:30081/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }'

# Login
curl -X POST http://$MINIKUBE_IP:30081/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "password123"
  }'
```

## Detailed Setup

### Step 1: Minikube Cluster Setup

The `setup-minikube.sh` script performs:

1. **Validates prerequisites** (Docker, kubectl, Minikube)
2. **Starts Minikube** with optimal resource allocation:
   - 4 CPUs
   - 8192 MB RAM
   - 20 GB disk
   - Docker driver
3. **Enables addons**:
   - `ingress` - NGINX Ingress Controller
   - `metrics-server` - Resource metrics for HPA
   - `dashboard` - Kubernetes Dashboard
   - `storage-provisioner` - Dynamic volume provisioning
4. **Configures kubectl** context
5. **Updates /etc/hosts** with `helabooking.local`

```bash
./setup-minikube.sh
```

**Expected Output:**
```
✅ Minikube cluster started
✅ Addons enabled
✅ kubectl context configured
📍 Minikube IP: 192.168.49.2
```

### Step 2: Build Docker Images

The `build-images.sh` script:

1. **Configures Docker** to use Minikube's Docker daemon
2. **Builds Maven project** (all modules)
3. **Builds Docker images** for all 6 services
4. **Tags images** with `latest` and version tags

```bash
./build-images.sh
```

**Expected Output:**
```
✅ Maven build completed
✅ user-service image built successfully
✅ event-service image built successfully
✅ booking-service image built successfully
✅ ticketing-service image built successfully
✅ notification-service image built successfully
✅ audit-service image built successfully
```

**Verify Images:**
```bash
eval $(minikube docker-env)
docker images | grep helabooking
```

### Step 3: Deploy to Kubernetes

The `deploy.sh` script deploys in this order:

1. **Namespace** - `helabooking`
2. **Secrets & ConfigMaps** - Database credentials, JWT secrets
3. **Databases** - 6 PostgreSQL StatefulSets
4. **RabbitMQ** - Message broker StatefulSet
5. **Microservices** - 6 service Deployments
6. **Ingress** - External routing
7. **HPA** - Auto-scaling policies

```bash
./deploy.sh
```

**Expected Timeline:**
- Namespace creation: instant
- Databases ready: 2-3 minutes
- RabbitMQ ready: 1-2 minutes
- Services ready: 2-3 minutes
- **Total**: ~5-8 minutes

**Monitor Progress:**
```bash
# Watch all pods
kubectl get pods -n helabooking -w

# Check specific service
kubectl get pods -n helabooking -l app=user-service

# View logs
kubectl logs -f deployment/user-service -n helabooking
```

## Configuration

### Kubernetes Resources

#### Namespace
```bash
k8s/namespace.yaml
```
- Namespace: `helabooking`
- Labels: `environment=development`

#### Secrets
```bash
k8s/secrets.yaml
```
- `postgres-secret`: Database credentials (postgres/postgres)
- `rabbitmq-secret`: RabbitMQ credentials (guest/guest)
- `jwt-secret`: JWT signing key

**Update Secrets:**
```bash
# Encode new password
echo -n 'newpassword' | base64

# Edit secret
kubectl edit secret postgres-secret -n helabooking
```

#### ConfigMap
```bash
k8s/configmap.yaml
```
- RabbitMQ connection details
- Service URLs for inter-service communication
- JWT expiration time

**Update ConfigMap:**
```bash
kubectl edit configmap helabooking-config -n helabooking

# Restart pods to pick up changes
kubectl rollout restart deployment/user-service -n helabooking
```

### Resource Limits

Each microservice has:
```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

Each database has:
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

**Adjust Resources:**
```bash
kubectl edit deployment user-service -n helabooking
```

### Replicas and Scaling

**Current Configuration:**
- User Service: 2 replicas
- Event Service: 2 replicas
- Booking Service: 2 replicas
- Ticketing Service: 2 replicas
- Notification Service: 2 replicas
- Audit Service: 2 replicas

**Manual Scaling:**
```bash
# Scale up
kubectl scale deployment user-service --replicas=3 -n helabooking

# Scale down
kubectl scale deployment user-service --replicas=1 -n helabooking
```

**Auto-Scaling (HPA):**
- Min replicas: 2
- Max replicas: 5
- CPU threshold: 70%
- Memory threshold: 80%

```bash
# View HPA status
kubectl get hpa -n helabooking

# Describe HPA
kubectl describe hpa user-service-hpa -n helabooking
```

## Accessing Services

### NodePort Access (Recommended for Development)

Get Minikube IP:
```bash
MINIKUBE_IP=$(minikube ip)
echo $MINIKUBE_IP
```

**Service Endpoints:**

| Service | URL | Port |
|---------|-----|------|
| User Service | `http://$MINIKUBE_IP:30081` | 30081 |
| Event Service | `http://$MINIKUBE_IP:30082` | 30082 |
| Booking Service | `http://$MINIKUBE_IP:30083` | 30083 |
| RabbitMQ Management | `http://$MINIKUBE_IP:31672` | 31672 |

**Example API Calls:**

```bash
# User Registration
curl -X POST http://$MINIKUBE_IP:30081/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john",
    "email": "john@example.com",
    "password": "password123"
  }'

# User Login
curl -X POST http://$MINIKUBE_IP:30081/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john",
    "password": "password123"
  }'

# Create Event
curl -X POST http://$MINIKUBE_IP:30082/api/events \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Tech Conference 2024",
    "location": "Convention Center",
    "eventDate": "2024-12-15T10:00:00",
    "capacity": 100
  }'

# Create Booking
curl -X POST http://$MINIKUBE_IP:30083/api/bookings \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "eventId": 1,
    "numberOfTickets": 2
  }'
```

### Ingress Access

Ensure `helabooking.local` is in `/etc/hosts`:
```bash
echo "$(minikube ip) helabooking.local" | sudo tee -a /etc/hosts
```

**Ingress Endpoints:**

| Service | URL |
|---------|-----|
| User Service | `http://helabooking.local/user/api/users/register` |
| Event Service | `http://helabooking.local/event/api/events` |
| Booking Service | `http://helabooking.local/booking/api/bookings` |

### Port Forwarding (Alternative)

```bash
# Forward User Service
kubectl port-forward -n helabooking deployment/user-service 8081:8081

# Access at http://localhost:8081

# Forward RabbitMQ Management
kubectl port-forward -n helabooking statefulset/rabbitmq 15672:15672

# Access at http://localhost:15672
```

### Database Access

```bash
# Port forward to a database
kubectl port-forward -n helabooking statefulset/userdb 5432:5432

# Connect with psql
psql -h localhost -U postgres -d userdb
# Password: postgres
```

## Monitoring and Management

### Kubernetes Dashboard

```bash
# Open dashboard
minikube dashboard

# Get dashboard URL
minikube dashboard --url
```

### Pod Logs

```bash
# View logs from all pods of a service
kubectl logs -f deployment/user-service -n helabooking

# View logs from specific pod
kubectl logs -f user-service-5d7b8c9f4d-xyz12 -n helabooking

# View logs with timestamps
kubectl logs -f deployment/user-service -n helabooking --timestamps

# View previous logs (if pod restarted)
kubectl logs --previous user-service-5d7b8c9f4d-xyz12 -n helabooking

# Tail last 100 lines
kubectl logs --tail=100 deployment/user-service -n helabooking
```

### Pod Status and Details

```bash
# List all pods
kubectl get pods -n helabooking

# Wide output (shows node, IP)
kubectl get pods -n helabooking -o wide

# Describe pod (detailed info)
kubectl describe pod user-service-5d7b8c9f4d-xyz12 -n helabooking

# Get pod YAML
kubectl get pod user-service-5d7b8c9f4d-xyz12 -n helabooking -o yaml

# Watch pods (auto-refresh)
kubectl get pods -n helabooking -w
```

### Service Information

```bash
# List services
kubectl get svc -n helabooking

# Describe service
kubectl describe svc user-service -n helabooking

# Get service endpoints
kubectl get endpoints -n helabooking
```

### Resource Usage

```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods -n helabooking

# Specific pod resources
kubectl top pod user-service-5d7b8c9f4d-xyz12 -n helabooking
```

### RabbitMQ Management

Access RabbitMQ Management UI:
```bash
# Get Minikube IP
MINIKUBE_IP=$(minikube ip)

# Open in browser
echo "http://$MINIKUBE_IP:31672"
```

**Credentials:**
- Username: `guest`
- Password: `guest`

**Monitor:**
- Queues and messages
- Connections and channels
- Exchange bindings
- Message rates

### Events and Issues

```bash
# View cluster events
kubectl get events -n helabooking --sort-by='.lastTimestamp'

# Watch events
kubectl get events -n helabooking -w

# Cluster-wide events
kubectl get events --all-namespaces
```

## Troubleshooting

### Common Issues

#### 1. Pods Not Starting

**Symptom:** Pods stuck in `Pending` or `CrashLoopBackOff`

```bash
# Check pod status
kubectl get pods -n helabooking

# Describe pod for events
kubectl describe pod <pod-name> -n helabooking

# Check logs
kubectl logs <pod-name> -n helabooking
```

**Solutions:**

- **Pending**: Check resource availability
  ```bash
  kubectl top nodes
  kubectl describe node minikube
  ```

- **ImagePullBackOff**: Rebuild images
  ```bash
  ./build-images.sh
  ```

- **CrashLoopBackOff**: Check logs for application errors
  ```bash
  kubectl logs --previous <pod-name> -n helabooking
  ```

#### 2. Database Connection Issues

**Symptom:** Services log database connection errors

```bash
# Check database pods
kubectl get pods -n helabooking -l app=userdb

# Check database logs
kubectl logs statefulset/userdb -n helabooking

# Test database connectivity
kubectl exec -it deployment/user-service -n helabooking -- \
  nc -zv userdb-service 5432
```

**Solutions:**

- Wait for databases to be fully ready (check readiness probes)
- Verify secrets are correctly configured
  ```bash
  kubectl get secret postgres-secret -n helabooking -o yaml
  ```

#### 3. RabbitMQ Connection Issues

**Symptom:** Services can't connect to RabbitMQ

```bash
# Check RabbitMQ status
kubectl get pods -n helabooking -l app=rabbitmq

# Check RabbitMQ logs
kubectl logs statefulset/rabbitmq -n helabooking

# Test RabbitMQ connectivity
kubectl exec -it deployment/user-service -n helabooking -- \
  nc -zv rabbitmq-service 5672
```

**Solutions:**

- Ensure RabbitMQ is running and ready
- Check RabbitMQ secret
  ```bash
  kubectl get secret rabbitmq-secret -n helabooking -o yaml
  ```

#### 4. Ingress Not Working

**Symptom:** Cannot access services via Ingress

```bash
# Check Ingress status
kubectl get ingress -n helabooking

# Describe Ingress
kubectl describe ingress helabooking-ingress -n helabooking

# Check Ingress controller
kubectl get pods -n ingress-nginx
```

**Solutions:**

- Ensure Ingress addon is enabled
  ```bash
  minikube addons enable ingress
  ```

- Verify `/etc/hosts` entry
  ```bash
  cat /etc/hosts | grep helabooking.local
  ```

- Check Ingress controller logs
  ```bash
  kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
  ```

#### 5. Out of Resources

**Symptom:** Minikube runs out of memory/CPU

```bash
# Check resource usage
kubectl top nodes
kubectl top pods -n helabooking
```

**Solutions:**

- Increase Minikube resources
  ```bash
  minikube stop
  minikube delete
  minikube start --cpus=6 --memory=12288
  ```

- Reduce service replicas
  ```bash
  kubectl scale deployment --all --replicas=1 -n helabooking
  ```

- Adjust resource limits in manifests

### Debug Commands

```bash
# Execute shell in pod
kubectl exec -it <pod-name> -n helabooking -- /bin/bash

# Copy files from pod
kubectl cp helabooking/<pod-name>:/path/to/file ./local-file

# Check DNS resolution
kubectl exec -it deployment/user-service -n helabooking -- \
  nslookup userdb-service

# Test service connectivity
kubectl exec -it deployment/user-service -n helabooking -- \
  curl http://event-service:8082/actuator/health

# View pod environment variables
kubectl exec <pod-name> -n helabooking -- env
```

### Restart Services

```bash
# Restart specific deployment
kubectl rollout restart deployment/user-service -n helabooking

# Restart all deployments
kubectl rollout restart deployment -n helabooking

# Restart StatefulSet
kubectl rollout restart statefulset/rabbitmq -n helabooking
```

### Complete Reset

```bash
# Clean up all resources
./cleanup.sh

# Restart Minikube
minikube stop
minikube start

# Redeploy everything
./setup-minikube.sh
./build-images.sh
./deploy.sh
```

## Production Considerations

### For Production Deployment

#### 1. Security

- **Change all default credentials** in secrets
- **Use external secrets management** (HashiCorp Vault, AWS Secrets Manager)
- **Enable TLS/SSL** for Ingress
  ```yaml
  tls:
  - hosts:
    - helabooking.com
    secretName: helabooking-tls
  ```
- **Implement network policies**
- **Use RBAC** for access control
- **Enable Pod Security Standards**

#### 2. High Availability

- **Increase replicas** for services (3+ per service)
- **Use multi-zone databases** (managed PostgreSQL)
- **Deploy RabbitMQ cluster** (3+ nodes)
- **Configure pod anti-affinity** for spreading across nodes
- **Use PodDisruptionBudgets**

#### 3. Persistence

- **Use managed storage solutions** (AWS EBS, GCP Persistent Disks)
- **Configure backup strategies** for databases
- **Set appropriate retention policies**
- **Use StorageClass with proper provisioners**

#### 4. Monitoring and Logging

- **Prometheus** for metrics collection
- **Grafana** for visualization
- **ELK/EFK stack** for centralized logging
- **Jaeger/Zipkin** for distributed tracing
- **Alert Manager** for alerts

#### 5. CI/CD

- **Automate image builds** (GitHub Actions, GitLab CI)
- **Use image scanning** for vulnerabilities
- **Implement GitOps** (ArgoCD, Flux)
- **Blue-green or canary deployments**
- **Automated testing** in pipeline

#### 6. Configuration Management

- **Use Helm charts** for templating
- **Environment-specific configurations** (dev, staging, prod)
- **External configuration** (Spring Cloud Config)
- **Feature flags** for gradual rollouts

#### 7. Resource Optimization

- **Right-size resource requests/limits**
- **Use Vertical Pod Autoscaler** for recommendations
- **Implement cluster autoscaling**
- **Configure proper liveness/readiness probes**
- **Use node affinity** for workload placement

#### 8. Networking

- **Use Istio or Linkerd** for service mesh
- **Implement rate limiting**
- **Configure proper timeout values**
- **Use circuit breakers** (Resilience4j)
- **DNS-based service discovery**

### Recommended Production Stack

```yaml
Cloud Provider: AWS/GCP/Azure
Kubernetes: EKS/GKE/AKS (managed Kubernetes)
Database: RDS PostgreSQL / Cloud SQL
Message Broker: Amazon MQ / Cloud Pub/Sub
Ingress: AWS ALB / GCP Load Balancer + cert-manager
Monitoring: Prometheus + Grafana
Logging: ELK/EFK Stack
Tracing: Jaeger
Service Mesh: Istio
CI/CD: GitHub Actions + ArgoCD
Secrets: HashiCorp Vault / AWS Secrets Manager
Container Registry: ECR / GCR / ACR
```

## Useful Commands Reference

### Cluster Management

```bash
# Start Minikube
minikube start

# Stop Minikube
minikube stop

# Delete Minikube
minikube delete

# Get Minikube IP
minikube ip

# SSH into Minikube
minikube ssh

# View addons
minikube addons list

# Enable addon
minikube addons enable <addon-name>
```

### Deployment Management

```bash
# Apply manifests
kubectl apply -f k8s/

# Delete resources
kubectl delete -f k8s/

# Get all resources
kubectl get all -n helabooking

# Describe resource
kubectl describe <resource-type> <resource-name> -n helabooking

# Edit resource
kubectl edit <resource-type> <resource-name> -n helabooking

# Scale deployment
kubectl scale deployment <name> --replicas=<count> -n helabooking

# Rollout status
kubectl rollout status deployment/<name> -n helabooking

# Rollout history
kubectl rollout history deployment/<name> -n helabooking

# Undo rollout
kubectl rollout undo deployment/<name> -n helabooking
```

### Debugging

```bash
# Get pod logs
kubectl logs <pod-name> -n helabooking

# Stream logs
kubectl logs -f <pod-name> -n helabooking

# Execute command in pod
kubectl exec -it <pod-name> -n helabooking -- <command>

# Port forward
kubectl port-forward <resource>/<name> <local-port>:<remote-port> -n helabooking

# Copy files
kubectl cp <local-path> <namespace>/<pod>:<remote-path>

# Get events
kubectl get events -n helabooking --sort-by='.lastTimestamp'
```

## Cleanup

### Partial Cleanup

```bash
# Delete specific deployment
kubectl delete deployment user-service -n helabooking

# Delete all services
kubectl delete svc --all -n helabooking

# Delete all pods (will be recreated by deployments)
kubectl delete pods --all -n helabooking
```

### Complete Cleanup

```bash
# Run cleanup script
./cleanup.sh

# Or manually
kubectl delete namespace helabooking
```

### Reset Minikube

```bash
# Stop and delete
minikube stop
minikube delete

# Start fresh
./setup-minikube.sh
```

## Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Spring Boot on Kubernetes](https://spring.io/guides/gs/spring-boot-kubernetes/)
- [RabbitMQ on Kubernetes](https://www.rabbitmq.com/kubernetes/operator/operator-overview.html)

## Support and Contribution

For issues, questions, or contributions, please refer to the main project repository.

## License

MIT License
