#!/bin/bash

# HelaBooking Backend - Quick Start Guide
# This script helps you test the microservices locally

echo "========================================="
echo "HelaBooking Backend Quick Start"
echo "========================================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker is not running. Please start Docker first."
    exit 1
fi

echo "1. Starting infrastructure (RabbitMQ and PostgreSQL databases)..."
echo ""

# Start RabbitMQ
docker run -d --name helabooking-rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.12-management 2>/dev/null || echo "RabbitMQ container already exists"

# Start PostgreSQL databases
docker run -d --name helabooking-userdb -e POSTGRES_DB=userdb -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:15 2>/dev/null || echo "UserDB already exists"
docker run -d --name helabooking-eventdb -e POSTGRES_DB=eventdb -e POSTGRES_PASSWORD=postgres -p 5433:5432 postgres:15 2>/dev/null || echo "EventDB already exists"
docker run -d --name helabooking-bookingdb -e POSTGRES_DB=bookingdb -e POSTGRES_PASSWORD=postgres -p 5434:5432 postgres:15 2>/dev/null || echo "BookingDB already exists"
docker run -d --name helabooking-ticketingdb -e POSTGRES_DB=ticketingdb -e POSTGRES_PASSWORD=postgres -p 5435:5432 postgres:15 2>/dev/null || echo "TicketingDB already exists"
docker run -d --name helabooking-notificationdb -e POSTGRES_DB=notificationdb -e POSTGRES_PASSWORD=postgres -p 5436:5432 postgres:15 2>/dev/null || echo "NotificationDB already exists"
docker run -d --name helabooking-auditdb -e POSTGRES_DB=auditdb -e POSTGRES_PASSWORD=postgres -p 5437:5432 postgres:15 2>/dev/null || echo "AuditDB already exists"

echo ""
echo "Waiting for infrastructure to be ready..."
sleep 10

echo ""
echo "2. Infrastructure is ready!"
echo ""
echo "Next steps:"
echo "  - RabbitMQ Management UI: http://localhost:15672 (guest/guest)"
echo "  - Build services: mvn clean install"
echo "  - Run each service in separate terminals:"
echo "    cd user-service && mvn spring-boot:run"
echo "    cd event-service && mvn spring-boot:run"
echo "    cd booking-service && mvn spring-boot:run"
echo "    cd ticketing-service && mvn spring-boot:run"
echo "    cd notification-service && mvn spring-boot:run"
echo "    cd audit-service && mvn spring-boot:run"
echo ""
echo "Or use Docker Compose:"
echo "  docker-compose up"
echo ""
echo "========================================="
