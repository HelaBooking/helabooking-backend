# HelaBooking System Architecture

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Client Layer                                    │
│                         (Web/Mobile Applications)                            │
└────────────────┬────────────────┬────────────────┬─────────────────────────┘
                 │                │                │
                 ▼                ▼                ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                          API Gateway / Load Balancer                          │
└───────┬──────────────────┬────────────────┬──────────────────────────────────┘
        │                  │                │
        ▼                  ▼                ▼
┌───────────────┐  ┌──────────────┐  ┌─────────────────┐
│ User Service  │  │Event Service │  │Booking Service  │
│   (Port 8081) │  │  (Port 8082) │  │   (Port 8083)   │
├───────────────┤  ├──────────────┤  ├─────────────────┤
│ - JWT Auth    │  │ - CRUD Ops   │  │ - Sync to Event │
│ - Register    │  │ - Seat Mgmt  │  │ - Create Booking│
│ - Login       │  │ - Events DB  │  │ - Bookings DB   │
└───────┬───────┘  └──────┬───────┘  └────────┬────────┘
        │                 │                   │
        │ Publishes:      │ Publishes:        │ Publishes:
        │ user.registered │ event.created     │ booking.succeeded
        │                 │                   │
        └─────────────────┴───────────────────┴─────────┐
                                                         │
                                                         ▼
                                              ┌──────────────────┐
                                              │   RabbitMQ       │
                                              │ Message Broker   │
                                              │ (Port 5672)      │
                                              ├──────────────────┤
                                              │ Exchange:        │
                                              │ helabooking.     │
                                              │   exchange       │
                                              └────────┬─────────┘
                                                       │
                 ┌─────────────────────────────────────┼─────────────────┐
                 │                                     │                 │
                 ▼                                     ▼                 ▼
        ┌──────────────────┐              ┌──────────────────┐  ┌────────────────┐
        │Ticketing Service │              │Notification Svc  │  │ Audit Service  │
        │   (Port 8084)    │              │   (Port 8085)    │  │  (Port 8086)   │
        ├──────────────────┤              ├──────────────────┤  ├────────────────┤
        │ - Consumes:      │              │ - Consumes:      │  │ - Consumes:    │
        │   booking.       │              │   user.registered│  │   All events   │
        │   succeeded      │              │   event.created  │  │ - Audit Logs   │
        │ - Generate       │              │   booking.       │  │ - Compliance   │
        │   Tickets        │              │   succeeded      │  │ - Audit DB     │
        │ - Ticketing DB   │              │ - Send Emails    │  └────────────────┘
        └──────────────────┘              │ - Notification DB│
                                          └──────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          Database Layer (PostgreSQL)                         │
├──────────────┬──────────────┬──────────────┬──────────────┬────────────────┤
│ UserDB       │ EventDB      │ BookingDB    │ TicketingDB  │ NotificationDB │
│ (Port 5432)  │ (Port 5433)  │ (Port 5434)  │ (Port 5435)  │ (Port 5436)    │
└──────────────┴──────────────┴──────────────┴──────────────┴────────────────┘
                                           ┌────────────────┐
                                           │ AuditDB        │
                                           │ (Port 5437)    │
                                           └────────────────┘
```

## Communication Patterns

### Synchronous Communication (REST)
- **Client → Services**: HTTP/REST APIs
- **Booking Service → Event Service**: REST call to reserve seats

### Asynchronous Communication (Event-Driven)
- **User Service → RabbitMQ**: Publishes `user.registered` event
- **Event Service → RabbitMQ**: Publishes `event.created` event
- **Booking Service → RabbitMQ**: Publishes `booking.succeeded` event
- **RabbitMQ → Consumer Services**: Delivers events to:
  - Ticketing Service
  - Notification Service
  - Audit Service

## Event Flow Diagrams

### User Registration Flow
```
User → User Service → Database
          ↓
       RabbitMQ (user.registered)
          ↓
    ┌─────┴─────┐
    ↓           ↓
Notification  Audit
 Service     Service
    ↓           ↓
 Email DB   Audit DB
```

### Event Creation Flow
```
Admin → Event Service → Database
           ↓
        RabbitMQ (event.created)
           ↓
     ┌─────┴─────┐
     ↓           ↓
 Notification  Audit
  Service     Service
     ↓           ↓
  Email DB   Audit DB
```

### Booking Flow (Most Complex)
```
User → Booking Service ──(sync)──→ Event Service → Reserve Seats
          ↓                              ↓
       Save to DB                    Update DB
          ↓
       RabbitMQ (booking.succeeded)
          ↓
    ┌─────┴──────┬─────────┐
    ↓            ↓         ↓
Ticketing    Notification  Audit
 Service      Service     Service
    ↓            ↓         ↓
Generate      Send Email  Log Event
 Tickets         ↓         ↓
    ↓         Notif DB  Audit DB
Ticket DB
```

## Service Responsibilities

### Synchronous Services (API Layer)

**User Service**
- User registration and authentication
- JWT token generation and validation
- User profile management
- **Events Published**: `user.registered`

**Event Service**
- Event CRUD operations
- Event capacity management
- Seat reservation (called by Booking Service)
- **Events Published**: `event.created`

**Booking Service**
- Create bookings
- **Sync call** to Event Service for seat reservation
- Booking status management
- **Events Published**: `booking.succeeded`

### Asynchronous Services (Event Consumers)

**Ticketing Service**
- Listens to `booking.succeeded`
- Generates unique tickets for confirmed bookings
- Stores ticket information

**Notification Service**
- Listens to ALL events (`user.registered`, `event.created`, `booking.succeeded`)
- Sends email notifications
- Stores notification history

**Audit Service**
- Listens to ALL events
- Creates audit trail
- Compliance and monitoring

## Technology Stack

### Backend Framework
- **Spring Boot 3.2.0**
- **Java 17**
- **Maven** for dependency management

### Database
- **PostgreSQL 15** (one database per service)
- **Spring Data JPA** for ORM

### Message Broker
- **RabbitMQ 3.12** with Management UI
- **AMQP** protocol
- **Topic Exchange** for routing

### Security
- **Spring Security**
- **JWT (JSON Web Tokens)** for authentication
- **BCrypt** for password hashing

### Containerization
- **Docker** for individual services
- **Docker Compose** for orchestration

## Design Patterns

### Microservices Patterns
1. **Database per Service**: Each service has its own database
2. **API Gateway Pattern**: (Can be added in future)
3. **Event Sourcing**: Events stored in message broker
4. **CQRS**: Separation of write (sync) and read (async) operations

### Messaging Patterns
1. **Publish-Subscribe**: RabbitMQ topic exchange
2. **Event-Driven Architecture**: Async communication between services
3. **Message Queue**: Reliable message delivery

### Integration Patterns
1. **Synchronous RPC**: REST calls between services (Booking → Event)
2. **Asynchronous Messaging**: RabbitMQ for event propagation

## Scalability Considerations

### Horizontal Scaling
- Each service can be scaled independently
- Load balancer can distribute requests
- Message consumers can run multiple instances

### Data Consistency
- **Eventual Consistency**: Async services process events eventually
- **Strong Consistency**: Sync calls ensure immediate updates (seat reservation)

### Resilience
- **Circuit Breaker**: Can be added for sync calls
- **Retry Mechanism**: RabbitMQ handles message redelivery
- **Dead Letter Queue**: For failed messages

## Monitoring & Observability

### Logs
- Each service logs operations
- Centralized logging can be added (ELK stack)

### Metrics
- RabbitMQ Management UI for queue metrics
- Spring Boot Actuator endpoints available

### Tracing
- Distributed tracing can be added (Zipkin/Jaeger)

## Security Considerations

### Authentication & Authorization
- JWT tokens for user authentication
- Token validation on protected endpoints
- Stateless authentication

### Data Protection
- Password encryption with BCrypt
- HTTPS for production (to be configured)
- Database credentials in environment variables

### Network Security
- Internal service-to-service communication
- External API exposure through API Gateway (future enhancement)

## Future Enhancements

1. **API Gateway**: Add Spring Cloud Gateway
2. **Service Discovery**: Add Eureka/Consul
3. **Config Server**: Centralized configuration management
4. **Circuit Breaker**: Add Resilience4j
5. **Caching**: Add Redis for performance
6. **Monitoring**: Add Prometheus + Grafana
7. **Tracing**: Add distributed tracing
8. **Testing**: Add integration and E2E tests
9. **CI/CD**: Add automated pipelines
10. **Kubernetes**: Deploy to K8s for production
