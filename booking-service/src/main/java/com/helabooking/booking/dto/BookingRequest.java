package com.helabooking.booking.dto;

import com.helabooking.booking.model.TicketType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class BookingRequest {
    private Long userId;
    private Long eventId;
    private Integer numberOfTickets;
    private TicketType ticketType;
    private BigDecimal pricePerTicket;
}
