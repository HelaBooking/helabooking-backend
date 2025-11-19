# HelaBooking Backend

Spring Boot Microservices Backend for HelaBooking Event Management System

## Architecture Overview

<img width="1257" height="492" alt="Event Booking drawio (2)" src="https://github.com/user-attachments/assets/ca1df09e-7679-463b-bfb5-572afd764e10" />


This is a microservices-based event booking system built with Spring Boot, featuring:

- **Synchronous APIs**: User (JWT auth), Event (CRUD), and Booking services
- **Asynchronous Event-Driven Architecture**: RabbitMQ for inter-service communication
- **Async Consumers**: Ticketing, Notification, and Audit services
- **Containerized Deployment**: Docker Compose orchestration
- **Kubernetes Orchestration**: Production-ready Kubernetes deployment with Minikube

## Services

### 1. User Service (Port 8081)
- JWT-based authentication
- User registration and login
- Publishes `user.registered` events

### 2. Event Service (Port 8082)
- Full CRUD operations for events
- Seat reservation management
- Publishes `event.created` events

### 3. Booking Service (Port 8083)
- Creates bookings with sync call to Event Service
- Reserves seats in Event Service
- Publishes `booking.succeeded` events

### 4. Ticketing Service (Port 8084)
- Async consumer for `booking.succeeded` events
- Generates tickets for confirmed bookings

### 5. Notification Service (Port 8085)
- Async consumer for all events
- Sends notifications for user registration, event creation, and bookings

### 6. Audit Service (Port 8086)
- Async consumer for all events
- Logs all system events for audit trail

## Technology Stack

- **Framework**: Spring Boot 3.2.0
- **Language**: Java 17
- **Build Tool**: Maven
- **Message Broker**: RabbitMQ
- **Databases**: PostgreSQL (separate DB per service)
- **Security**: Spring Security with JWT
- **Containerization**: Docker & Docker Compose
- **Orchestration**: Kubernetes with Minikube (development) or EKS/GKE/AKS (production)

## Project Structure

```
helabooking-backend/
├── common/                      # Shared library (RabbitMQ config, events)
├── user-service/               # User service with JWT auth
├── event-service/              # Event CRUD service
├── booking-service/            # Booking service with sync calls
├── ticketing-service/          # Async ticket generation
├── notification-service/       # Async notifications
├── audit-service/              # Async audit logging
├── docker-compose.yml          # Orchestration configuration
└── pom.xml                     # Root Maven configuration
```

## Getting Started

### Prerequisites

- Java 17+
- Maven 3.6+
- Docker & Docker Compose
- Kubernetes & Minikube (for K8s deployment)

### Deployment Options

#### Option 1: Kubernetes with Minikube (Recommended)

**Quick Start (3 commands):**
```bash
./setup-minikube.sh   # Setup Minikube cluster
./build-images.sh     # Build Docker images
./deploy.sh           # Deploy to Kubernetes
```

**Or using Makefile:**
```bash
make all              # Full setup: setup + build + deploy
make status           # Check deployment status
make test             # Run API tests
```

**Access Services:**
```bash
# Get Minikube IP
MINIKUBE_IP=$(minikube ip)

# Service endpoints
User Service:        http://$MINIKUBE_IP:30081
Event Service:       http://$MINIKUBE_IP:30082
Booking Service:     http://$MINIKUBE_IP:30083
RabbitMQ Management: http://$MINIKUBE_IP:31672
```

📖 **See [k8s/README.md](k8s/README.md) and [KUBERNETES_GUIDE.md](KUBERNETES_GUIDE.md) for complete Kubernetes documentation.**

---

#### Option 2: Docker Compose (Development)

### Build the Project

```bash
# Build all services
mvn clean install
```

### Run with Docker Compose

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

### Run Locally (Development)

1. Start RabbitMQ:
```bash
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.12-management
```

2. Start PostgreSQL databases:
```bash
docker run -d --name userdb -e POSTGRES_DB=userdb -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:15
docker run -d --name eventdb -e POSTGRES_DB=eventdb -e POSTGRES_PASSWORD=postgres -p 5433:5432 postgres:15
docker run -d --name bookingdb -e POSTGRES_DB=bookingdb -e POSTGRES_PASSWORD=postgres -p 5434:5432 postgres:15
docker run -d --name ticketingdb -e POSTGRES_DB=ticketingdb -e POSTGRES_PASSWORD=postgres -p 5435:5432 postgres:15
docker run -d --name notificationdb -e POSTGRES_DB=notificationdb -e POSTGRES_PASSWORD=postgres -p 5436:5432 postgres:15
docker run -d --name auditdb -e POSTGRES_DB=auditdb -e POSTGRES_PASSWORD=postgres -p 5437:5432 postgres:15
```

3. Run each service:
```bash
cd user-service && mvn spring-boot:run
cd event-service && mvn spring-boot:run
cd booking-service && mvn spring-boot:run
cd ticketing-service && mvn spring-boot:run
cd notification-service && mvn spring-boot:run
cd audit-service && mvn spring-boot:run
```

## API Examples

### User Registration
```bash
curl -X POST http://localhost:8081/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john",
    "email": "john@example.com",
    "password": "password123"
  }'
```

### User Login
```bash
curl -X POST http://localhost:8081/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john",
    "password": "password123"
  }'
```

### Create Event
```bash
curl -X POST http://localhost:8082/api/events \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Tech Conference 2024",
    "location": "Convention Center",
    "eventDate": "2024-12-15T10:00:00",
    "capacity": 100
  }'
```

### Create Booking
```bash
curl -X POST http://localhost:8083/api/bookings \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "eventId": 1,
    "numberOfTickets": 2
  }'
```

## Event Flow

1. **User Registration Flow**:
   - User registers → User Service creates user → Publishes `user.registered` event
   - Notification Service sends welcome email
   - Audit Service logs the registration

2. **Event Creation Flow**:
   - Event created → Event Service saves event → Publishes `event.created` event
   - Notification Service notifies admins
   - Audit Service logs the event creation

3. **Booking Flow**:
   - Booking request → Booking Service calls Event Service (sync)
   - Event Service reserves seats → Booking Service publishes `booking.succeeded` event
   - Ticketing Service generates tickets
   - Notification Service sends confirmation email
   - Audit Service logs the booking

## RabbitMQ Management

**Docker Compose:**
- URL: http://localhost:15672
- Username: guest
- Password: guest

**Kubernetes:**
- URL: http://$(minikube ip):31672
- Username: guest
- Password: guest

## Service Endpoints

### Docker Compose

- User Service: http://localhost:8081
- Event Service: http://localhost:8082
- Booking Service: http://localhost:8083
- Ticketing Service: http://localhost:8084
- Notification Service: http://localhost:8085
- Audit Service: http://localhost:8086

### Kubernetes (NodePort)

```bash
MINIKUBE_IP=$(minikube ip)
```

- User Service: http://$MINIKUBE_IP:30081
- Event Service: http://$MINIKUBE_IP:30082
- Booking Service: http://$MINIKUBE_IP:30083
- RabbitMQ Management: http://$MINIKUBE_IP:31672

### Kubernetes (Ingress)

Add to `/etc/hosts`: `$(minikube ip) helabooking.local`

- User Service: http://helabooking.local/user/
- Event Service: http://helabooking.local/event/
- Booking Service: http://helabooking.local/booking/

## Database Ports (Docker Compose)

- User DB: 5432
- Event DB: 5433
- Booking DB: 5434
- Ticketing DB: 5435
- Notification DB: 5436
- Audit DB: 5437

## Kubernetes Features

Our Kubernetes deployment includes:

- ✅ **StatefulSets** for databases and RabbitMQ with persistent storage
- ✅ **Deployments** for microservices with 2 replicas each
- ✅ **Horizontal Pod Autoscaling (HPA)** based on CPU/Memory (2-5 replicas)
- ✅ **ConfigMaps & Secrets** for configuration management
- ✅ **Services** for internal service-to-service communication
- ✅ **Ingress** with NGINX for external routing
- ✅ **Resource limits** for CPU and memory
- ✅ **Health checks** (liveness and readiness probes)
- ✅ **Automated scripts** for setup, build, and deployment

### Kubernetes Quick Commands

```bash
# Using Makefile
make help             # Show all available commands
make all              # Full setup
make status           # Check status
make logs-user        # View user service logs
make scale-up         # Scale services to 3 replicas
make clean            # Clean up resources

# Using kubectl directly
kubectl get pods -n helabooking                    # List all pods
kubectl logs -f deployment/user-service -n helabooking  # View logs
kubectl scale deployment/user-service --replicas=3 -n helabooking  # Scale
kubectl port-forward deployment/user-service 8081:8081 -n helabooking  # Port forward
```

For detailed Kubernetes documentation:
- 📘 [k8s/README.md](k8s/README.md) - Quick start guide
- 📗 [KUBERNETES_GUIDE.md](KUBERNETES_GUIDE.md) - Complete deployment guide

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License
