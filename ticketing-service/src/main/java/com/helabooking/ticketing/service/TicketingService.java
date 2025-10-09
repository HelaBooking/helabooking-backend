package com.helabooking.ticketing.service;

import com.helabooking.ticketing.model.Ticket;
import com.helabooking.ticketing.repository.TicketRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class TicketingService {

    @Autowired
    private TicketRepository ticketRepository;

    public void generateTickets(Long bookingId, Long userId, Long eventId, Integer numberOfTickets) {
        for (int i = 0; i < numberOfTickets; i++) {
            Ticket ticket = new Ticket();
            ticket.setBookingId(bookingId);
            ticket.setUserId(userId);
            ticket.setEventId(eventId);
            ticket.setTicketNumber(generateTicketNumber());
            ticketRepository.save(ticket);
        }
    }

    private String generateTicketNumber() {
        return "TICKET-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}
