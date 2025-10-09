package com.helabooking.common.event;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class BookingSucceededEvent {
    private Long bookingId;
    private Long userId;
    private Long eventId;
    private Integer numberOfTickets;
    private LocalDateTime timestamp;
}
