# Postman Collection Guide - HellaBooking Backend API

## Overview
The updated Postman collection includes all endpoints for the complete HellaBooking microservices backend, including newly implemented features.

## Services & Ports

| Service | Port | Base URL Variable |
|---------|------|------------------|
| User Service | 8081 | `{{baseUrl1}}` |
| Event Service | 8082 | `{{baseUrl2}}` |
| Booking Service | 8083 | `{{baseUrl3}}` |
| Ticketing Service | 8084 | `{{baseUrl4}}` |

---

## 📁 Collection Structure

### 1. User Service (8081)
User authentication, profile management, and role-based access control.

#### Endpoints:
- **GET** `/api/users/health` - Health check
- **POST** `/api/users/register` - Register new user with role
- **POST** `/api/users/register` - Register admin user (example)
- **POST** `/api/users/login` - User login (saves token & userId)
- **GET** `/api/users/{userId}/profile` - Get user profile ✨ NEW
- **PUT** `/api/users/{userId}/role` - Update user role ✨ NEW

#### Features:
- ✅ User roles: USER, AUDITOR, ADMIN
- ✅ Automatic token capture on login
- ✅ Profile management with role information

---

### 2. Event Service (8082)
Event creation, management, and publishing with enhanced metadata.

#### Endpoints:
- **GET** `/api/events/health` - Health check
- **POST** `/api/events` - Create event with full metadata ✨ ENHANCED
  - Note: **Admin-only** (requires Authorization: Bearer <ADMIN_TOKEN>)
- **POST** `/api/events` - Create recurring event (example) ✨ NEW
- **GET** `/api/events` - Get all events
- **GET** `/api/events/{eventId}` - Get event by ID
- **PUT** `/api/events/{eventId}` - Update event ✨ ENHANCED
  - Note: **Admin-only** (requires Authorization: Bearer <ADMIN_TOKEN>)
- **POST** `/api/events/{eventId}/publish` - Publish event ✨ NEW
  - Note: **Admin-only** (requires Authorization: Bearer <ADMIN_TOKEN>)
- **GET** `/api/events/published` - Get published events only ✨ NEW
- **POST** `/api/events/{eventId}/reserve?seats={number}` - Reserve seats
- **DELETE** `/api/events/{eventId}` - Delete event
  - Note: **Admin-only** (requires Authorization: Bearer <ADMIN_TOKEN>)

#### Features:
- ✅ Enhanced metadata: description, venue, agenda, categories
- ✅ Event status workflow (DRAFT → PUBLISHED)
- ✅ Recurring events with patterns (DAILY, WEEKLY, MONTHLY)
- ✅ Multi-session event support
- ✅ Automatic eventId capture

---

### 3. Booking Service (8083)
Booking management with multiple ticket types and pricing.

#### Endpoints:
- **GET** `/api/bookings/health` - Health check
- **POST** `/api/bookings` - Create booking (PAID) ✨ ENHANCED
- **POST** `/api/bookings` - Create VIP booking (example) ✨ NEW
- **POST** `/api/bookings` - Create free booking (example) ✨ NEW
- **POST** `/api/bookings` - Create group booking (example) ✨ NEW
- **GET** `/api/bookings` - Get all bookings
- **GET** `/api/bookings/{bookingId}` - Get booking by ID
- **GET** `/api/bookings/user/{userId}` - Get bookings by user

#### Features:
- ✅ Ticket types: FREE, PAID, VIP, GROUP
- ✅ Automatic price calculation (pricePerTicket × numberOfTickets)
- ✅ Overbooking prevention with synchronization
- ✅ Automatic bookingId capture

---

### 4. Ticketing Service (8084) ✨ NEW SECTION
Digital ticket generation and retrieval with QR codes and barcodes.

#### Endpoints:
- **GET** `/api/tickets/health` - Health check ✨ NEW
- **GET** `/api/tickets/booking/{bookingId}` - Get tickets by booking ✨ NEW
- **GET** `/api/tickets/user/{userId}` - Get tickets by user ✨ NEW
- **GET** `/api/tickets/{ticketNumber}` - Get ticket by number ✨ NEW

#### Features:
- ✅ Automatic QR code generation
- ✅ Automatic barcode generation
- ✅ Ticket retrieval by booking, user, or ticket number
- ✅ Unique ticket numbers

---

## 🔧 Collection Variables

The collection uses variables for easy configuration:

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `baseUrl1` | User Service URL | `http://localhost:8081` |
| `baseUrl2` | Event Service URL | `http://localhost:8082` |
| `baseUrl3` | Booking Service URL | `http://localhost:8083` |
| `baseUrl4` | Ticketing Service URL | `http://localhost:8084` |
| `token` | JWT token (auto-set) | Auto-captured from login |
| `adminToken` | Admin JWT token (auto-set) | Auto-captured from admin login |
| `userId` | Current user ID (auto-set) | Auto-captured from registration/login |
| `eventId` | Current event ID (auto-set) | Auto-captured from event creation |
| `recurringEventId` | Recurring event ID | Auto-captured |
| `bookingId` | Current booking ID (auto-set) | Auto-captured from booking creation |
| `vipBookingId` | VIP booking ID | Auto-captured |

---

## 🚀 Quick Start Workflow

### Complete Booking Flow:

1. **Register User**
   ```
   POST {{baseUrl1}}/api/users/register
   → Captures: userId, token
   ```

2. **Create Event**
   ```
   POST {{baseUrl2}}/api/events
   → Captures: eventId
   ```

3. **Publish Event**
   ```
   POST {{baseUrl2}}/api/events/{{eventId}}/publish
   → Makes event public
   ```

4. **Create Booking**
   ```
   POST {{baseUrl3}}/api/bookings
   → Captures: bookingId
   → Generates tickets automatically via RabbitMQ
   ```

5. **Get Tickets**
   ```
   GET {{baseUrl4}}/api/tickets/booking/{{bookingId}}
   → Returns tickets with QR codes and barcodes
   ```

---

## 📝 Example Payloads

### Register User with Role
```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "SecurePass123",
  "role": "USER"
}
```

**Roles:** `USER`, `AUDITOR`, `ADMIN`

---

### Create Event (Full Metadata)
```json
{
  "name": "Tech Conference 2025",
  "description": "Annual technology conference featuring latest innovations",
  "location": "San Francisco Convention Center",
  "venue": "Main Hall A",
  "agenda": "09:00 - Registration\n10:00 - Keynote Speech\n12:00 - Lunch Break\n13:00 - Technical Sessions\n17:00 - Closing Remarks",
  "categories": "Technology,Conference,Networking,Innovation",
  "eventDate": "2025-06-15T09:00:00",
  "endDate": "2025-06-15T18:00:00",
  "isRecurring": false,
  "recurrencePattern": null,
  "isMultiSession": true,
  "capacity": 500
}
```

---

### Create Recurring Event
```json
{
  "name": "Weekly Yoga Class",
  "description": "Relaxing yoga sessions for all levels",
  "location": "Wellness Center",
  "venue": "Studio 2",
  "agenda": "Warm-up, Main session, Cool-down",
  "categories": "Wellness,Yoga,Fitness",
  "eventDate": "2025-07-01T18:00:00",
  "endDate": "2025-07-01T19:30:00",
  "isRecurring": true,
  "recurrencePattern": "WEEKLY",
  "isMultiSession": false,
  "capacity": 30
}
```

**Recurrence Patterns:** `DAILY`, `WEEKLY`, `MONTHLY`

---

### Create Booking with Ticket Type
```json
{
  "userId": 1,
  "eventId": 1,
  "numberOfTickets": 3,
  "ticketType": "PAID",
  "pricePerTicket": 99.99
}
```

**Ticket Types:**
- `FREE` - No cost (set pricePerTicket to 0)
- `PAID` - Standard paid tickets
- `VIP` - Premium tickets with higher price
- `GROUP` - Group bookings (often discounted)

---

### Update User Role
```json
{
  "role": "AUDITOR"
}
```

---

## 🔄 Response Examples

### User Registration Response
```json
{
  "id": 1,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "username": "john_doe",
  "email": "john@example.com",
  "role": "USER"
}
```

### Event Response
```json
{
  "id": 1,
  "name": "Tech Conference 2025",
  "description": "Annual technology conference...",
  "location": "San Francisco Convention Center",
  "venue": "Main Hall A",
  "agenda": "09:00 - Registration...",
  "categories": "Technology,Conference,Networking,Innovation",
  "eventDate": "2025-06-15T09:00:00",
  "endDate": "2025-06-15T18:00:00",
  "isRecurring": false,
  "recurrencePattern": null,
  "isMultiSession": true,
  "capacity": 500,
  "availableSeats": 500,
  "status": "DRAFT",
  "publishedAt": null
}
```

### Booking Response
```json
{
  "id": 1,
  "userId": 1,
  "eventId": 1,
  "numberOfTickets": 3,
  "ticketType": "PAID",
  "totalPrice": 299.97,
  "status": "CONFIRMED",
  "createdAt": "2025-11-17T12:00:00"
}
```

### Ticket Response
```json
{
  "id": 1,
  "bookingId": 1,
  "userId": 1,
  "eventId": 1,
  "ticketNumber": "TICKET-ABC12345",
  "qrCode": "QR-TICKET-ABC12345-XYZ789AB",
  "barcode": "BC-TICKETABC123451731849600000",
  "createdAt": "2025-11-17T12:00:00"
}
```

---

## ⚡ Testing Tips

### 1. Run Requests in Order
Execute requests in the following sequence for automatic variable capture:
1. Register User → Captures `userId` and `token`
2. Create Event → Captures `eventId`
3. Publish Event → Makes event available
4. Create Booking → Captures `bookingId` and triggers ticket generation
5. Get Tickets → View generated tickets with QR/barcodes

### 2. Test Different Ticket Types
Try creating bookings with different ticket types to see pricing differences:
- FREE: `pricePerTicket: 0`
- PAID: `pricePerTicket: 99.99`
- VIP: `pricePerTicket: 299.99`
- GROUP: `pricePerTicket: 79.99` (10+ tickets)

### 3. Test Overbooking Prevention
1. Create an event with small capacity (e.g., 10)
2. Create a booking for 8 tickets
3. Try creating another booking for 5 tickets
4. The second booking should fail or status should be "FAILED"

### 4. Test Event Publishing
1. Create event (status will be DRAFT)
2. Try getting published events - should not include the draft
3. Publish the event
4. Get published events again - should now include it

### 5. Test Recurring Events
Create events with different recurrence patterns:
- Daily meetings
- Weekly classes
- Monthly seminars

---

## 🔐 Authentication

Currently, the API uses JWT tokens:
- Token is automatically captured from login/registration responses
- Token is stored in the `token` collection variable
- Admin token stored separately in `adminToken`

**Future Enhancement:** Add Authorization header with Bearer token for protected endpoints.

---

## 🐛 Troubleshooting

### Services Not Responding
```bash
# Check if all services are running
docker compose ps

# View service logs
docker compose logs user-service
docker compose logs event-service
docker compose logs booking-service
docker compose logs ticketing-service
```

### Tickets Not Generated
Tickets are generated asynchronously via RabbitMQ when a booking succeeds.
1. Check booking status is "CONFIRMED"
2. Wait a few seconds for event processing
3. Verify RabbitMQ is running: `docker compose ps rabbitmq`

### Invalid JSON Errors
Ensure date/time fields use ISO 8601 format: `2025-06-15T09:00:00`

---

## 📦 Import Instructions

### Importing to Postman:
1. Open Postman
2. Click "Import" button
3. Select `postman_collection.json`
4. The collection will be imported with all variables pre-configured

### Environment Setup:
All service URLs are configured as collection variables. If running on different ports or hosts, update the variables:
- `baseUrl1` through `baseUrl4`

---

## 🆕 What's New in This Version

### New Endpoints (12 total):
1. `GET /api/users/{userId}/profile` - User profile with role
2. `PUT /api/users/{userId}/role` - Update user role
3. `POST /api/events/{id}/publish` - Publish event
4. `GET /api/events/published` - Get published events
5. `GET /api/tickets/health` - Ticketing health check
6. `GET /api/tickets/booking/{bookingId}` - Get tickets by booking
7. `GET /api/tickets/user/{userId}` - Get tickets by user
8. `GET /api/tickets/{ticketNumber}` - Get ticket by number

### Enhanced Endpoints:
- `POST /api/users/register` - Now accepts role parameter
- `POST /api/events` - Enhanced with full metadata (11 new fields)
- `PUT /api/events/{id}` - Enhanced with full metadata
- `POST /api/bookings` - Enhanced with ticket types and pricing

### New Example Requests:
- Register Admin User
- Create Recurring Event
- Create VIP Booking
- Create Free Booking
- Create Group Booking

---

## 📞 Support

For API issues or questions:
- Check service health endpoints first
- Review logs: `docker compose logs [service-name]`
- Refer to `IMPLEMENTATION_SUMMARY.md` for feature details
- Check `API_TESTING_GUIDE.md` for curl examples

---

**Last Updated:** November 17, 2025  
**Collection Version:** 2.0 (Enhanced)  
**Services Covered:** User, Event, Booking, Ticketing
