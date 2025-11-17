package com.helabooking.event.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "events")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Event {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(length = 2000)
    private String description;

    @Column(nullable = false)
    private String location;

    private String venue;

    @Column(length = 5000)
    private String agenda;

    private String categories;

    @Column(nullable = false)
    private LocalDateTime eventDate;

    private LocalDateTime endDate;

    private Boolean isRecurring = false;

    private String recurrencePattern; // e.g., "DAILY", "WEEKLY", "MONTHLY"

    private Boolean isMultiSession = false;

    @Column(nullable = false)
    private Integer capacity;

    @Column(nullable = false)
    private Integer availableSeats;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private EventStatus status = EventStatus.DRAFT;

    private LocalDateTime publishedAt;

    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (availableSeats == null) {
            availableSeats = capacity;
        }
        if (status == null) {
            status = EventStatus.DRAFT;
        }
        if (isRecurring == null) {
            isRecurring = false;
        }
        if (isMultiSession == null) {
            isMultiSession = false;
        }
    }
}
