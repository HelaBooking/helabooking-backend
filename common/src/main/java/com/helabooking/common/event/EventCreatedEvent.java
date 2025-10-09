package com.helabooking.common.event;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class EventCreatedEvent {
    private Long eventId;
    private String eventName;
    private String location;
    private LocalDateTime eventDate;
    private Integer capacity;
    private LocalDateTime timestamp;
}
