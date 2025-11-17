package com.helabooking.booking.dto;

import com.helabooking.booking.model.TicketType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class BookingResponse {
    private Long id;
    private Long userId;
    private Long eventId;
    private Integer numberOfTickets;
    private TicketType ticketType;
    private BigDecimal totalPrice;
    private String status;
    private LocalDateTime createdAt;
}
