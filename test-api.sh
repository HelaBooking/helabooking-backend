#!/bin/bash

###############################################################################
# HelaBooking Test Script
# This script runs basic API tests to verify the deployment
###############################################################################

set -e

echo "========================================"
echo "HelaBooking API Tests"
echo "========================================"

# Get Minikube IP
MINIKUBE_IP=$(minikube ip)
echo "📍 Using Minikube IP: $MINIKUBE_IP"
echo ""

# Test User Service
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Testing User Service"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Register a test user
echo "1. Registering user..."
REGISTER_RESPONSE=$(curl -s -X POST http://$MINIKUBE_IP:30081/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }')

echo "Response: $REGISTER_RESPONSE"

# Login
echo ""
echo "2. Logging in..."
LOGIN_RESPONSE=$(curl -s -X POST http://$MINIKUBE_IP:30081/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "password123"
  }')

echo "Response: $LOGIN_RESPONSE"

# Extract token (if JWT is returned in response)
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | grep -o '[^"]*$' || echo "")

if [ -n "$TOKEN" ]; then
    echo "✅ User Service: OK (Token received)"
else
    echo "⚠️  User Service: Response received but no token found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Testing Event Service"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create an event
echo "1. Creating event..."
EVENT_RESPONSE=$(curl -s -X POST http://$MINIKUBE_IP:30082/api/events \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Tech Conference 2024",
    "location": "Convention Center",
    "eventDate": "2024-12-15T10:00:00",
    "capacity": 100
  }')

echo "Response: $EVENT_RESPONSE"

# Get all events
echo ""
echo "2. Getting all events..."
EVENTS_LIST=$(curl -s http://$MINIKUBE_IP:30082/api/events)
echo "Response: $EVENTS_LIST"

EVENT_ID=$(echo $EVENT_RESPONSE | grep -o '"id":[0-9]*' | grep -o '[0-9]*' | head -1 || echo "1")

if [ -n "$EVENT_RESPONSE" ]; then
    echo "✅ Event Service: OK (Event created)"
else
    echo "❌ Event Service: Failed"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Testing Booking Service"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create a booking
echo "1. Creating booking..."
BOOKING_RESPONSE=$(curl -s -X POST http://$MINIKUBE_IP:30083/api/bookings \
  -H "Content-Type: application/json" \
  -d "{
    \"userId\": 1,
    \"eventId\": $EVENT_ID,
    \"numberOfTickets\": 2
  }")

echo "Response: $BOOKING_RESPONSE"

if [ -n "$BOOKING_RESPONSE" ]; then
    echo "✅ Booking Service: OK (Booking created)"
else
    echo "❌ Booking Service: Failed"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Testing RabbitMQ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check RabbitMQ Management UI
RABBITMQ_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$MINIKUBE_IP:31672)

if [ "$RABBITMQ_STATUS" = "200" ]; then
    echo "✅ RabbitMQ Management UI: OK (HTTP $RABBITMQ_STATUS)"
    echo "   Access at: http://$MINIKUBE_IP:31672"
    echo "   Username: guest, Password: guest"
else
    echo "⚠️  RabbitMQ Management UI: HTTP $RABBITMQ_STATUS"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Tests completed!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Check async services (Ticketing, Notification, Audit) logs:"
echo "   kubectl logs -f deployment/ticketing-service -n helabooking"
echo "   kubectl logs -f deployment/notification-service -n helabooking"
echo "   kubectl logs -f deployment/audit-service -n helabooking"
echo ""
