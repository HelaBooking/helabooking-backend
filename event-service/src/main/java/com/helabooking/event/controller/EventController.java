package com.helabooking.event.controller;

import com.helabooking.event.dto.EventRequest;
import com.helabooking.event.dto.EventResponse;
import com.helabooking.event.service.EventService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/events")
public class EventController {

    @Autowired
    private EventService eventService;

    @Autowired
    private com.helabooking.event.security.JwtTokenProvider jwtTokenProvider;
    @PostMapping
    public ResponseEntity<EventResponse> createEvent(@RequestBody EventRequest request,
                                                     @RequestHeader(value = "Authorization", required = false) String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ")) {
            return ResponseEntity.status(401).build();
        }
        String token = authorization.substring(7);
        if (!jwtTokenProvider.validateToken(token)) {
            return ResponseEntity.status(401).build();
        }
        String role = jwtTokenProvider.getRoleFromToken(token);
        if (role == null || !"ADMIN".equals(role)) {
            return ResponseEntity.status(403).build();
    
        }
        return ResponseEntity.ok(eventService.createEvent(request));
        
    }

    @GetMapping("/{id}")
    public ResponseEntity<EventResponse> getEvent(@PathVariable Long id) {
        return ResponseEntity.ok(eventService.getEvent(id));
    }
    

    @GetMapping
    public ResponseEntity<List<EventResponse>> getAllEvents() {
        return ResponseEntity.ok(eventService.getAllEvents());
    }

    @PutMapping("/{id}")
    public ResponseEntity<EventResponse> updateEvent(@PathVariable Long id,
                                                     @RequestBody EventRequest request,
                                                     @RequestHeader(value = "Authorization", required = false) String authorization) {
        if (!isAdmin(authorization)) {
            return ResponseEntity.status(authorization == null ? 401 : 403).build();
        }
        return ResponseEntity.ok(eventService.updateEvent(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteEvent(@PathVariable Long id,
                                            @RequestHeader(value = "Authorization", required = false) String authorization) {
        if (!isAdmin(authorization)) {
            return ResponseEntity.status(authorization == null ? 401 : 403).build();
        }
        eventService.deleteEvent(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/reserve")
    public ResponseEntity<Boolean> reserveSeats(@PathVariable Long id, @RequestParam Integer seats) {
        // Public endpoint - called by booking-service internally
        return ResponseEntity.ok(eventService.reserveSeats(id, seats));
    }

    @PostMapping("/{id}/publish")
    public ResponseEntity<EventResponse> publishEvent(@PathVariable Long id,
                                                      @RequestHeader(value = "Authorization", required = false) String authorization) {
        if (!isAdmin(authorization)) {
            return ResponseEntity.status(authorization == null ? 401 : 403).build();
        }
        return ResponseEntity.ok(eventService.publishEvent(id));
    }

    private boolean isAdmin(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ")) {
            return false;
        }
        String token = authorization.substring(7);
        if (!jwtTokenProvider.validateToken(token)) {
            return false;
        }
        String role = jwtTokenProvider.getRoleFromToken(token);
        return role != null && "ADMIN".equals(role);
    }

    @GetMapping("/published")
    public ResponseEntity<List<EventResponse>> getPublishedEvents() {
        return ResponseEntity.ok(eventService.getPublishedEvents());
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Event Service is running");
    }
}

/*
Example curl commands for the endpoints:

# Create event (ADMIN only)
curl -X POST http://localhost:8080/api/events \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer <ADMIN_TOKEN>" \
    -d '{"title":"Conference","description":"Annual conference","startTime":"2025-01-01T09:00:00","endTime":"2025-01-01T17:00:00","availableSeats":100}'

# Get event by id
curl http://localhost:8080/api/events/1

# Get all events
curl http://localhost:8080/api/events

# Update event (ADMIN only)
curl -X PUT http://localhost:8080/api/events/1 \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer <ADMIN_TOKEN>" \
    -d '{"title":"Updated Conference","description":"Updated details","startTime":"2025-01-01T10:00:00","endTime":"2025-01-01T18:00:00","availableSeats":80}'

# Delete event (ADMIN only)
curl -X DELETE http://localhost:8080/api/events/1 \
    -H "Authorization: Bearer <ADMIN_TOKEN>"

# Reserve seats (query parameter "seats")
curl -X POST "http://localhost:8080/api/events/1/reserve?seats=2"

# Health
curl http://localhost:8080/api/events/health
*/