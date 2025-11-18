package com.helabooking.booking.service;

import com.helabooking.booking.client.EventServiceClient;
import com.helabooking.booking.dto.BookingRequest;
import com.helabooking.booking.dto.BookingResponse;
import com.helabooking.booking.model.Booking;
import com.helabooking.booking.repository.BookingRepository;
import com.helabooking.common.config.RabbitMQConfig;
import com.helabooking.common.event.BookingSucceededEvent;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class BookingService {

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private EventServiceClient eventServiceClient;

    @Autowired
    private RabbitTemplate rabbitTemplate;

    public BookingResponse createBooking(BookingRequest request) {
        Booking booking = new Booking();
        booking.setUserId(request.getUserId());
        booking.setEventId(request.getEventId());
        booking.setNumberOfTickets(request.getNumberOfTickets());
        booking.setTicketType(request.getTicketType() != null ? request.getTicketType() : com.helabooking.booking.model.TicketType.PAID);
        booking.setStatus("PENDING");

        // Calculate total price
        if (request.getPricePerTicket() != null) {
            booking.setTotalPrice(request.getPricePerTicket().multiply(
                java.math.BigDecimal.valueOf(request.getNumberOfTickets())
            ));
        }

        booking = bookingRepository.save(booking);

        // Sync call to Event Service to reserve seats
        boolean seatsReserved = eventServiceClient.reserveSeats(
                request.getEventId(),
                request.getNumberOfTickets()
        );

        if (seatsReserved) {
            booking.setStatus("CONFIRMED");
            booking = bookingRepository.save(booking);

            // Publish booking.succeeded event
            try {
                BookingSucceededEvent event = new BookingSucceededEvent(
                        booking.getId(),
                        booking.getUserId(),
                        booking.getEventId(),
                        booking.getNumberOfTickets(),
                        LocalDateTime.now()
                );
                System.out.println("Publishing booking.succeeded event for booking " + booking.getId());
                rabbitTemplate.convertAndSend(
                        RabbitMQConfig.EXCHANGE_NAME,
                        RabbitMQConfig.BOOKING_SUCCEEDED_KEY,
                        event
                );
                System.out.println("Successfully published booking.succeeded event for booking " + booking.getId());
            } catch (Exception e) {
                System.err.println("Failed to publish booking.succeeded event for booking " + booking.getId() + ": " + e.getMessage());
                e.printStackTrace();
            }
        } else {
            booking.setStatus("FAILED");
            booking = bookingRepository.save(booking);
        }

        return mapToResponse(booking);
    }

    public BookingResponse getBooking(Long id) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking not found"));
        return mapToResponse(booking);
    }

    public List<BookingResponse> getBookingsByUserId(Long userId) {
        return bookingRepository.findByUserId(userId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<BookingResponse> getAllBookings() {
        return bookingRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private BookingResponse mapToResponse(Booking booking) {
        return new BookingResponse(
                booking.getId(),
                booking.getUserId(),
                booking.getEventId(),
                booking.getNumberOfTickets(),
                booking.getTicketType(),
                booking.getTotalPrice(),
                booking.getStatus(),
                booking.getCreatedAt()
        );
    }
}
