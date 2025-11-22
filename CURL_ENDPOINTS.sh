#!/bin/bash

# ============================================================================
# Hel aBooking Backend - API Endpoints Testing Guide
# ============================================================================
# This script contains curl commands for all implemented endpoints
# Update BASE_URL if services are running on different hosts/ports
# ============================================================================

# Service URLs
USER_SERVICE="http://localhost:8081"
EVENT_SERVICE="http://localhost:8082"
BOOKING_SERVICE="http://localhost:8083"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Hel aBooking Backend - API Testing Guide            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

# ============================================================================
# USER SERVICE ENDPOINTS (Port: 8080)
# ============================================================================
echo -e "\n${BLUE}═══ USER SERVICE ENDPOINTS ═══${NC}"

# Health Check
echo -e "\n${GREEN}1. User Service - Health Check${NC}"
echo "curl -s $USER_SERVICE/api/users/health"
curl -s $USER_SERVICE/api/users/health | jq .
echo ""

# Register User
echo -e "\n${GREEN}2. User Service - Register${NC}"
echo "curl -X POST $USER_SERVICE/api/users/register \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"username\":\"john_doe\",\"email\":\"john@example.com\",\"password\":\"SecurePass123\"}'"
REGISTER_RESPONSE=$(curl -s -X POST $USER_SERVICE/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"username":"john_doe","email":"john@example.com","password":"SecurePass123"}')
echo "$REGISTER_RESPONSE" | jq .
USER_ID=$(echo "$REGISTER_RESPONSE" | jq -r '.id // empty')
USER_TOKEN=$(echo "$REGISTER_RESPONSE" | jq -r '.token // empty')
echo ""

# Login User
echo -e "\n${GREEN}3. User Service - Login${NC}"
echo "curl -X POST $USER_SERVICE/api/users/login \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"username\":\"john_doe\",\"password\":\"SecurePass123\"}'"
LOGIN_RESPONSE=$(curl -s -X POST $USER_SERVICE/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"username":"john_doe","password":"SecurePass123"}')
echo "$LOGIN_RESPONSE" | jq .
USER_ID=$(echo "$LOGIN_RESPONSE" | jq -r '.id // 1')
TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token // empty')
echo ""

# ============================================================================
# EVENT SERVICE ENDPOINTS (Port: 8081)
# ============================================================================
echo -e "\n${BLUE}═══ EVENT SERVICE ENDPOINTS ═══${NC}"

# Health Check
echo -e "\n${GREEN}4. Event Service - Health Check${NC}"
echo "curl -s $EVENT_SERVICE/api/events/health"
curl -s $EVENT_SERVICE/api/events/health | jq .
echo ""

# Create Event
echo -e "\n${GREEN}5. Event Service - Create Event${NC}"
echo "curl -X POST $EVENT_SERVICE/api/events \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"name\":\"Tech Conference 2025\",\"location\":\"San Francisco, CA\",\"eventDate\":\"2025-06-15T09:00:00\",\"capacity\":500}'"
CREATE_EVENT=$(curl -s -X POST $EVENT_SERVICE/api/events \
  -H "Content-Type: application/json" \
  -d '{"name":"Tech Conference 2025","location":"San Francisco, CA","eventDate":"2025-06-15T09:00:00","capacity":500}')
echo "$CREATE_EVENT" | jq .
EVENT_ID=$(echo "$CREATE_EVENT" | jq -r '.id // 1')
echo ""

# Get All Events
echo -e "\n${GREEN}6. Event Service - Get All Events${NC}"
echo "curl -s $EVENT_SERVICE/api/events"
curl -s $EVENT_SERVICE/api/events | jq .
echo ""

# Get Event by ID
echo -e "\n${GREEN}7. Event Service - Get Event by ID${NC}"
echo "curl -s $EVENT_SERVICE/api/events/$EVENT_ID"
curl -s $EVENT_SERVICE/api/events/$EVENT_ID | jq .
echo ""

# Update Event
echo -e "\n${GREEN}8. Event Service - Update Event${NC}"
echo "curl -X PUT $EVENT_SERVICE/api/events/$EVENT_ID \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"name\":\"Tech Conference 2025 - Updated\",\"location\":\"San Francisco, CA\",\"eventDate\":\"2025-06-15T10:00:00\",\"capacity\":600}'"
curl -s -X PUT $EVENT_SERVICE/api/events/$EVENT_ID \
  -H "Content-Type: application/json" \
  -d '{"name":"Tech Conference 2025 - Updated","location":"San Francisco, CA","eventDate":"2025-06-15T10:00:00","capacity":600}' | jq .
echo ""

# Reserve Seats
echo -e "\n${GREEN}9. Event Service - Reserve Seats${NC}"
echo "curl -X POST \"$EVENT_SERVICE/api/events/$EVENT_ID/reserve?seats=25\""
curl -s -X POST "$EVENT_SERVICE/api/events/$EVENT_ID/reserve?seats=25" | jq .
echo ""

# Delete Event
echo -e "\n${GREEN}10. Event Service - Delete Event${NC}"
echo "curl -X DELETE $EVENT_SERVICE/api/events/$EVENT_ID"
curl -s -X DELETE $EVENT_SERVICE/api/events/$EVENT_ID
echo ""

# ============================================================================
# BOOKING SERVICE ENDPOINTS (Port: 8082)
# ============================================================================
echo -e "\n${BLUE}═══ BOOKING SERVICE ENDPOINTS ═══${NC}"

# Health Check
echo -e "\n${GREEN}11. Booking Service - Health Check${NC}"
echo "curl -s $BOOKING_SERVICE/api/bookings/health"
curl -s $BOOKING_SERVICE/api/bookings/health | jq .
echo ""

# Create Booking
echo -e "\n${GREEN}12. Booking Service - Create Booking${NC}"
echo "curl -X POST $BOOKING_SERVICE/api/bookings \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"userId\":$USER_ID,\"eventId\":$EVENT_ID,\"numberOfTickets\":3}'"
CREATE_BOOKING=$(curl -s -X POST $BOOKING_SERVICE/api/bookings \
  -H "Content-Type: application/json" \
  -d "{\"userId\":$USER_ID,\"eventId\":$EVENT_ID,\"numberOfTickets\":3}")
echo "$CREATE_BOOKING" | jq .
BOOKING_ID=$(echo "$CREATE_BOOKING" | jq -r '.id // 1')
echo ""

# Get All Bookings
echo -e "\n${GREEN}13. Booking Service - Get All Bookings${NC}"
echo "curl -s $BOOKING_SERVICE/api/bookings"
curl -s $BOOKING_SERVICE/api/bookings | jq .
echo ""

# Get Booking by ID
echo -e "\n${GREEN}14. Booking Service - Get Booking by ID${NC}"
echo "curl -s $BOOKING_SERVICE/api/bookings/$BOOKING_ID"
curl -s $BOOKING_SERVICE/api/bookings/$BOOKING_ID | jq .
echo ""

# Get Bookings by User ID
echo -e "\n${GREEN}15. Booking Service - Get Bookings by User ID${NC}"
echo "curl -s $BOOKING_SERVICE/api/bookings/user/$USER_ID"
curl -s $BOOKING_SERVICE/api/bookings/user/$USER_ID | jq .
echo ""

# ============================================================================
# SUMMARY
# ============================================================================
echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                  API TESTING SUMMARY                       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo -e "\n${GREEN}Total Endpoints Implemented: 15${NC}"
echo ""
echo "User Service (8081):"
echo "  - POST   /api/users/register"
echo "  - POST   /api/users/login"
echo "  - GET    /api/users/health"
echo ""
echo "Event Service (8082):"
echo "  - POST   /api/events"
echo "  - GET    /api/events"
echo "  - GET    /api/events/{id}"
echo "  - PUT    /api/events/{id}"
echo "  - DELETE /api/events/{id}"
echo "  - POST   /api/events/{id}/reserve"
echo "  - GET    /api/events/health"
echo ""
echo "Booking Service (8083):"
echo "  - POST   /api/bookings"
echo "  - GET    /api/bookings"
echo "  - GET    /api/bookings/{id}"
echo "  - GET    /api/bookings/user/{userId}"
echo "  - GET    /api/bookings/health"
echo ""
echo -e "${GREEN}Note: Make sure services are running before executing this script.${NC}"
echo -e "${GREEN}Run 'docker compose up -d --build' to start all services.${NC}\n"
