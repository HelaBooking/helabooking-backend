package com.helabooking.event.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class EventResponse {
    private Long id;
    private String name;
    private String location;
    private LocalDateTime eventDate;
    private Integer capacity;
    private Integer availableSeats;
}
