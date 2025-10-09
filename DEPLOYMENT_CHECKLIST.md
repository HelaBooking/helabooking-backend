# Deployment & Testing Checklist

This checklist helps you deploy and test the HelaBooking backend system.

## Pre-Deployment Checklist

### System Requirements
- [ ] Docker installed and running
- [ ] Docker Compose installed
- [ ] Java 17 installed (for local development)
- [ ] Maven 3.6+ installed (for local development)
- [ ] At least 8GB RAM available
- [ ] Ports 5432-5437, 5672, 8081-8086, 15672 are free

### Build Verification
```bash
# Clone the repository
git clone https://github.com/HelaBooking/helabooking-backend.git
cd helabooking-backend

# Build the project
mvn clean package -DskipTests

# Verify all JARs were created
ls -l */target/*.jar
```

Expected output: 7 JAR files

## Deployment Options

### Option 1: Docker Compose (Recommended for Testing)

```bash
# Start all services
docker-compose up -d

# Check all containers are running
docker ps

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Remove all data (clean start)
docker-compose down -v
```

**Expected Containers (13 total):**
- [ ] helabooking-rabbitmq
- [ ] helabooking-userdb
- [ ] helabooking-eventdb
- [ ] helabooking-bookingdb
- [ ] helabooking-ticketingdb
- [ ] helabooking-notificationdb
- [ ] helabooking-auditdb
- [ ] helabooking-user-service
- [ ] helabooking-event-service
- [ ] helabooking-booking-service
- [ ] helabooking-ticketing-service
- [ ] helabooking-notification-service
- [ ] helabooking-audit-service

### Option 2: Local Development

```bash
# Start infrastructure
./start-infrastructure.sh

# Build project
mvn clean install

# Run each service in a separate terminal
cd user-service && mvn spring-boot:run
cd event-service && mvn spring-boot:run
cd booking-service && mvn spring-boot:run
cd ticketing-service && mvn spring-boot:run
cd notification-service && mvn spring-boot:run
cd audit-service && mvn spring-boot:run
```

## Service Health Checks

### Check All Services are Running

```bash
# User Service
curl http://localhost:8081/api/users/health

# Event Service
curl http://localhost:8082/api/events/health

# Booking Service
curl http://localhost:8083/api/bookings/health
```

**Expected Response:** `"User/Event/Booking Service is running"`

### Check RabbitMQ
- Open browser: http://localhost:15672
- Login: guest/guest
- [ ] Check "helabooking.exchange" exists
- [ ] Check 3 queues exist

### Check Databases
```bash
# Check all databases are accessible
docker exec -it helabooking-userdb psql -U postgres -c "\l"
docker exec -it helabooking-eventdb psql -U postgres -c "\l"
docker exec -it helabooking-bookingdb psql -U postgres -c "\l"
```

## End-to-End Testing

### Test 1: User Registration Flow

```bash
# Register a user
curl -X POST http://localhost:8081/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }'
```

**Expected Results:**
- [ ] Returns JWT token and user details
- [ ] Check notification service logs: "Welcome email sent"
- [ ] Check audit service logs: "User registration logged"
- [ ] Verify in database:
  ```bash
  docker exec -it helabooking-userdb psql -U postgres -d userdb -c "SELECT * FROM users;"
  docker exec -it helabooking-notificationdb psql -U postgres -d notificationdb -c "SELECT * FROM notifications;"
  docker exec -it helabooking-auditdb psql -U postgres -d auditdb -c "SELECT * FROM audit_logs;"
  ```

### Test 2: Event Creation Flow

```bash
# Create an event
curl -X POST http://localhost:8082/api/events \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Conference",
    "location": "Test Hall",
    "eventDate": "2024-12-20T10:00:00",
    "capacity": 100
  }'
```

**Expected Results:**
- [ ] Returns event with ID and availableSeats=100
- [ ] Check notification service logs: "Event created notification"
- [ ] Check audit service logs: "Event creation logged"
- [ ] Verify in database:
  ```bash
  docker exec -it helabooking-eventdb psql -U postgres -d eventdb -c "SELECT * FROM events;"
  ```

### Test 3: Booking Flow (Complete End-to-End)

```bash
# Create a booking
curl -X POST http://localhost:8083/api/bookings \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "eventId": 1,
    "numberOfTickets": 5
  }'
```

**Expected Results:**
- [ ] Returns booking with status="CONFIRMED"
- [ ] Verify event seats reduced:
  ```bash
  curl http://localhost:8082/api/events/1
  # Should show availableSeats=95
  ```
- [ ] Check ticketing service logs: "Generated 5 tickets"
- [ ] Check notification service logs: "Booking confirmation sent"
- [ ] Check audit service logs: "Booking logged"
- [ ] Verify in databases:
  ```bash
  # Booking created
  docker exec -it helabooking-bookingdb psql -U postgres -d bookingdb -c "SELECT * FROM bookings;"
  
  # Tickets generated
  docker exec -it helabooking-ticketingdb psql -U postgres -d ticketingdb -c "SELECT * FROM tickets;"
  
  # Notification sent
  docker exec -it helabooking-notificationdb psql -U postgres -d notificationdb -c "SELECT * FROM notifications WHERE subject LIKE '%Booking%';"
  
  # Audit logged
  docker exec -it helabooking-auditdb psql -U postgres -d auditdb -c "SELECT * FROM audit_logs WHERE event_type='booking.succeeded';"
  ```

### Test 4: RabbitMQ Message Flow

**Check RabbitMQ UI:**
1. Open http://localhost:15672
2. Go to "Queues" tab
3. [ ] Verify messages were consumed from all queues
4. [ ] Check "user.registered.queue" - should show consumers
5. [ ] Check "event.created.queue" - should show consumers
6. [ ] Check "booking.succeeded.queue" - should show consumers

## Performance Testing

### Load Test
```bash
# Create multiple bookings rapidly
for i in {1..10}; do
  curl -X POST http://localhost:8083/api/bookings \
    -H "Content-Type: application/json" \
    -d "{\"userId\": 1, \"eventId\": 1, \"numberOfTickets\": 1}"
done

# Verify all tickets were generated
docker exec -it helabooking-ticketingdb psql -U postgres -d ticketingdb -c "SELECT COUNT(*) FROM tickets;"
```

## Troubleshooting Guide

### Service Won't Start

**Check Logs:**
```bash
docker logs helabooking-user-service
docker logs helabooking-event-service
docker logs helabooking-booking-service
```

**Common Issues:**
1. Database not ready - Wait 30 seconds and restart service
2. Port already in use - Stop conflicting service or change port
3. RabbitMQ not ready - Check RabbitMQ logs

### Database Connection Failed

```bash
# Restart database
docker restart helabooking-userdb

# Check database logs
docker logs helabooking-userdb

# Test connection
docker exec -it helabooking-userdb psql -U postgres -c "SELECT version();"
```

### RabbitMQ Issues

```bash
# Restart RabbitMQ
docker restart helabooking-rabbitmq

# Check RabbitMQ status
docker exec helabooking-rabbitmq rabbitmq-diagnostics status

# View RabbitMQ logs
docker logs helabooking-rabbitmq
```

### Messages Not Being Consumed

1. Check RabbitMQ UI - Are messages in queue?
2. Check consumer service logs
3. Verify exchange and queue bindings in RabbitMQ UI
4. Restart consumer service

## Cleanup

### Remove All Containers and Data
```bash
docker-compose down -v
docker system prune -f
```

### Remove All Images
```bash
docker-compose down --rmi all -v
```

## Production Deployment Considerations

Before deploying to production:

- [ ] Change default passwords in docker-compose.yml
- [ ] Use environment-specific configuration files
- [ ] Enable HTTPS/TLS
- [ ] Set up proper logging (ELK stack)
- [ ] Configure monitoring (Prometheus + Grafana)
- [ ] Set up alerts for failures
- [ ] Configure backup strategy for databases
- [ ] Set up CI/CD pipeline
- [ ] Perform security audit
- [ ] Load testing and capacity planning
- [ ] Document recovery procedures
- [ ] Set up API Gateway
- [ ] Configure rate limiting
- [ ] Set up proper secret management (Vault, etc.)

## Success Indicators

The system is working correctly if:

✅ All 13 containers are running
✅ All health checks pass
✅ User registration creates notification and audit log
✅ Event creation creates notification and audit log
✅ Booking creates tickets, notification, and audit log
✅ Event seats are correctly reserved
✅ RabbitMQ shows all queues have consumers
✅ No errors in service logs

## Contact & Support

For issues or questions:
1. Check the logs first
2. Review the ARCHITECTURE.md for system design
3. Review the API_TESTING_GUIDE.md for API examples
4. Check RabbitMQ Management UI for message flow
5. Verify database data manually

---

**Last Updated:** 2024-10-09
**Version:** 1.0.0
