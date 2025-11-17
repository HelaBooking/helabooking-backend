package com.helabooking.event.dto;

import com.helabooking.event.model.EventStatus;
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
    private String description;
    private String location;
    private String venue;
    private String agenda;
    private String categories;
    private LocalDateTime eventDate;
    private LocalDateTime endDate;
    private Boolean isRecurring;
    private String recurrencePattern;
    private Boolean isMultiSession;
    private Integer capacity;
    private Integer availableSeats;
    private EventStatus status;
    private LocalDateTime publishedAt;
}
