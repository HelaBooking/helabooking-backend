package com.helabooking.event.service;

import com.helabooking.common.config.RabbitMQConfig;
import com.helabooking.common.event.EventCreatedEvent;
import com.helabooking.event.dto.EventRequest;
import com.helabooking.event.dto.EventResponse;
import com.helabooking.event.model.Event;
import com.helabooking.event.repository.EventRepository;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class EventService {

    @Autowired
    private EventRepository eventRepository;

    @Autowired
    private RabbitTemplate rabbitTemplate;

    public EventResponse createEvent(EventRequest request) {
        Event event = new Event();
        event.setName(request.getName());
        event.setLocation(request.getLocation());
        event.setEventDate(request.getEventDate());
        event.setCapacity(request.getCapacity());

        event = eventRepository.save(event);

        // Publish event.created event
        EventCreatedEvent createdEvent = new EventCreatedEvent(
                event.getId(),
                event.getName(),
                event.getLocation(),
                event.getEventDate(),
                event.getCapacity(),
                LocalDateTime.now()
        );
        rabbitTemplate.convertAndSend(
                RabbitMQConfig.EXCHANGE_NAME,
                RabbitMQConfig.EVENT_CREATED_KEY,
                createdEvent
        );

        return mapToResponse(event);
    }

    public EventResponse getEvent(Long id) {
        Event event = eventRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Event not found"));
        return mapToResponse(event);
    }

    public List<EventResponse> getAllEvents() {
        return eventRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public EventResponse updateEvent(Long id, EventRequest request) {
        Event event = eventRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Event not found"));

        event.setName(request.getName());
        event.setLocation(request.getLocation());
        event.setEventDate(request.getEventDate());
        event.setCapacity(request.getCapacity());

        event = eventRepository.save(event);
        return mapToResponse(event);
    }

    public void deleteEvent(Long id) {
        if (!eventRepository.existsById(id)) {
            throw new RuntimeException("Event not found");
        }
        eventRepository.deleteById(id);
    }

    public boolean reserveSeats(Long eventId, Integer numberOfSeats) {
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new RuntimeException("Event not found"));

        if (event.getAvailableSeats() < numberOfSeats) {
            return false;
        }

        event.setAvailableSeats(event.getAvailableSeats() - numberOfSeats);
        eventRepository.save(event);
        return true;
    }

    private EventResponse mapToResponse(Event event) {
        return new EventResponse(
                event.getId(),
                event.getName(),
                event.getLocation(),
                event.getEventDate(),
                event.getCapacity(),
                event.getAvailableSeats()
        );
    }
}
