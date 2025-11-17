package com.helabooking.ticketing.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TicketResponse {
    private Long id;
    private Long bookingId;
    private Long userId;
    private Long eventId;
    private String ticketNumber;
    private String qrCode;
    private String barcode;
    private LocalDateTime createdAt;
}
