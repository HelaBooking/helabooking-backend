package com.helabooking.ticketing.service;

import com.helabooking.ticketing.model.Ticket;
import com.helabooking.ticketing.repository.TicketRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
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
            ticket.setQrCode(generateQRCode(ticket.getTicketNumber()));
            ticket.setBarcode(generateBarcode(ticket.getTicketNumber()));
            ticketRepository.save(ticket);
        }
    }

    public List<Ticket> getTicketsByBookingId(Long bookingId) {
        return ticketRepository.findByBookingId(bookingId);
    }

    public List<Ticket> getTicketsByUserId(Long userId) {
        return ticketRepository.findByUserId(userId);
    }

    public Ticket getTicketByTicketNumber(String ticketNumber) {
        return ticketRepository.findByTicketNumber(ticketNumber)
                .orElseThrow(() -> new RuntimeException("Ticket not found"));
    }

    private String generateTicketNumber() {
        return "TICKET-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    private String generateQRCode(String ticketNumber) {
        // Generate QR code data (in production, use a QR code library like ZXing)
        return "QR-" + ticketNumber + "-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    private String generateBarcode(String ticketNumber) {
        // Generate barcode (in production, use a barcode library)
        return "BC-" + ticketNumber.replace("-", "") + System.currentTimeMillis();
    }
}
