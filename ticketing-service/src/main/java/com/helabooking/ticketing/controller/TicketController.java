package com.helabooking.ticketing.controller;

import com.helabooking.ticketing.dto.TicketResponse;
import com.helabooking.ticketing.model.Ticket;
import com.helabooking.ticketing.service.TicketingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/tickets")
public class TicketController {

    @Autowired
    private TicketingService ticketingService;

    @GetMapping("/booking/{bookingId}")
    public ResponseEntity<List<TicketResponse>> getTicketsByBooking(@PathVariable Long bookingId) {
        List<Ticket> tickets = ticketingService.getTicketsByBookingId(bookingId);
        return ResponseEntity.ok(tickets.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList()));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<TicketResponse>> getTicketsByUser(@PathVariable Long userId) {
        List<Ticket> tickets = ticketingService.getTicketsByUserId(userId);
        return ResponseEntity.ok(tickets.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList()));
    }

    @GetMapping("/{ticketNumber}")
    public ResponseEntity<TicketResponse> getTicketByNumber(@PathVariable String ticketNumber) {
        Ticket ticket = ticketingService.getTicketByTicketNumber(ticketNumber);
        return ResponseEntity.ok(mapToResponse(ticket));
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Ticketing Service is running");
    }

    private TicketResponse mapToResponse(Ticket ticket) {
        return new TicketResponse(
                ticket.getId(),
                ticket.getBookingId(),
                ticket.getUserId(),
                ticket.getEventId(),
                ticket.getTicketNumber(),
                ticket.getQrCode(),
                ticket.getBarcode(),
                ticket.getCreatedAt()
        );
    }
}
