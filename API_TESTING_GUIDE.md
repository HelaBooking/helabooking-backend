# API Testing Guide

This guide provides examples for testing all the HelaBooking microservices.

## Prerequisites

Ensure all services are running:
- User Service: http://localhost:8081
- Event Service: http://localhost:8082
- Booking Service: http://localhost:8083
- Ticketing Service: http://localhost:8084
- Notification Service: http://localhost:8085
- Audit Service: http://localhost:8086

## 1. User Service Tests

### Register a new user
```bash
curl -X POST http://localhost:8081/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@example.com",
    "password": "securePassword123"
  }'
```

Expected response:
```json
{
  "token": "eyJhbGc...",
  "username": "john_doe",
  "email": "john@example.com"
}
```

This will trigger:
- ✅ `user.registered` event published to RabbitMQ
- ✅ Notification service sends welcome email
- ✅ Audit service logs the registration

### Login
```bash
curl -X POST http://localhost:8081/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "password": "securePassword123"
  }'
```

### Health Check
```bash
curl http://localhost:8081/api/users/health
```

## 2. Event Service Tests

### Create an event
```bash
curl -X POST http://localhost:8082/api/events \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Spring Boot Conference 2024",
    "location": "Convention Center, Hall A",
    "eventDate": "2024-12-15T10:00:00",
    "capacity": 100
  }'
```

Expected response:
```json
{
  "id": 1,
  "name": "Spring Boot Conference 2024",
  "location": "Convention Center, Hall A",
  "eventDate": "2024-12-15T10:00:00",
  "capacity": 100,
  "availableSeats": 100
}
```

This will trigger:
- ✅ `event.created` event published to RabbitMQ
- ✅ Notification service notifies admins
- ✅ Audit service logs the event creation

### Get all events
```bash
curl http://localhost:8082/api/events
```

### Get event by ID
```bash
curl http://localhost:8082/api/events/1
```

### Update event
```bash
curl -X PUT http://localhost:8082/api/events/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Spring Boot Conference 2024 - UPDATED",
    "location": "Convention Center, Hall B",
    "eventDate": "2024-12-15T10:00:00",
    "capacity": 150
  }'
```

### Delete event
```bash
curl -X DELETE http://localhost:8082/api/events/1
```

## 3. Booking Service Tests

### Create a booking
```bash
curl -X POST http://localhost:8083/api/bookings \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "eventId": 1,
    "numberOfTickets": 3
  }'
```

Expected response:
```json
{
  "id": 1,
  "userId": 1,
  "eventId": 1,
  "numberOfTickets": 3,
  "status": "CONFIRMED",
  "createdAt": "2024-10-09T10:30:00"
}
```

This will trigger:
1. **Synchronous call** to Event Service to reserve seats
2. ✅ `booking.succeeded` event published to RabbitMQ
3. ✅ Ticketing service generates 3 tickets
4. ✅ Notification service sends confirmation email
5. ✅ Audit service logs the booking

### Get all bookings
```bash
curl http://localhost:8083/api/bookings
```

### Get booking by ID
```bash
curl http://localhost:8083/api/bookings/1
```

### Get bookings by user
```bash
curl http://localhost:8083/api/bookings/user/1
```

## 4. Testing Event-Driven Architecture

### Verify RabbitMQ Queues
Access RabbitMQ Management UI: http://localhost:15672
- Username: `guest`
- Password: `guest`

You should see:
- Exchange: `helabooking.exchange`
- Queues:
  - `user.registered.queue`
  - `event.created.queue`
  - `booking.succeeded.queue`

### Check Logs

**Ticketing Service logs:**
```
Received booking.succeeded event: BookingSucceededEvent(...)
Generated 3 tickets for booking 1
```

**Notification Service logs:**
```
Received user.registered event: UserRegisteredEvent(...)
Notification sent to john@example.com: Welcome to HelaBooking

Received event.created event: EventCreatedEvent(...)
Notification sent to admin@helabooking.com: New Event Created

Received booking.succeeded event: BookingSucceededEvent(...)
Notification sent to user-1@helabooking.com: Booking Confirmed
```

**Audit Service logs:**
```
Received user.registered event: UserRegisteredEvent(...)
Audit log created: user.registered - User Registration

Received event.created event: EventCreatedEvent(...)
Audit log created: event.created - Event Creation

Received booking.succeeded event: BookingSucceededEvent(...)
Audit log created: booking.succeeded - Booking Success
```

## Complete End-to-End Test Scenario

```bash
# 1. Register a user
USER_RESPONSE=$(curl -s -X POST http://localhost:8081/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "alice",
    "email": "alice@example.com",
    "password": "password123"
  }')
echo "User registered: $USER_RESPONSE"

# 2. Create an event
EVENT_RESPONSE=$(curl -s -X POST http://localhost:8082/api/events \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Tech Meetup 2024",
    "location": "Tech Hub",
    "eventDate": "2024-11-20T18:00:00",
    "capacity": 50
  }')
echo "Event created: $EVENT_RESPONSE"

# 3. Create a booking (assuming userId=1 and eventId=1)
BOOKING_RESPONSE=$(curl -s -X POST http://localhost:8083/api/bookings \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "eventId": 1,
    "numberOfTickets": 2
  }')
echo "Booking created: $BOOKING_RESPONSE"

# 4. Verify event seats were reserved
EVENT_CHECK=$(curl -s http://localhost:8082/api/events/1)
echo "Event after booking: $EVENT_CHECK"
# Should show availableSeats: 48

# 5. Check all bookings
ALL_BOOKINGS=$(curl -s http://localhost:8083/api/bookings)
echo "All bookings: $ALL_BOOKINGS"
```

## Database Queries

You can connect to the databases to verify data:

```bash
# User database
docker exec -it helabooking-userdb psql -U postgres -d userdb -c "SELECT * FROM users;"

# Event database
docker exec -it helabooking-eventdb psql -U postgres -d eventdb -c "SELECT * FROM events;"

# Booking database
docker exec -it helabooking-bookingdb psql -U postgres -d bookingdb -c "SELECT * FROM bookings;"

# Ticketing database
docker exec -it helabooking-ticketingdb psql -U postgres -d ticketingdb -c "SELECT * FROM tickets;"

# Notification database
docker exec -it helabooking-notificationdb psql -U postgres -d notificationdb -c "SELECT * FROM notifications;"

# Audit database
docker exec -it helabooking-auditdb psql -U postgres -d auditdb -c "SELECT * FROM audit_logs;"
```

## Troubleshooting

### Service not responding
```bash
# Check if service is running
curl http://localhost:808X/actuator/health

# Check Docker containers
docker ps

# Check logs
docker logs helabooking-user-service
docker logs helabooking-event-service
docker logs helabooking-booking-service
```

### RabbitMQ issues
```bash
# Restart RabbitMQ
docker restart helabooking-rabbitmq

# Check RabbitMQ logs
docker logs helabooking-rabbitmq
```

### Database connection issues
```bash
# Check database is running
docker ps | grep postgres

# Restart database
docker restart helabooking-userdb
```
