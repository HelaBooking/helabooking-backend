package com.helabooking.audit.consumer;

import com.helabooking.audit.service.AuditService;
import com.helabooking.common.config.RabbitMQConfig;
import com.helabooking.common.event.BookingSucceededEvent;
import com.helabooking.common.event.EventCreatedEvent;
import com.helabooking.common.event.UserRegisteredEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class EventConsumer {

    private static final Logger logger = LoggerFactory.getLogger(EventConsumer.class);

    @Autowired
    private AuditService auditService;

    @RabbitListener(queues = RabbitMQConfig.USER_REGISTERED_QUEUE)
    public void handleUserRegistered(UserRegisteredEvent event) {
        logger.info("Received user.registered event: {}", event);
        auditService.logEvent(
                "user.registered",
                "User Registration",
                String.format("User %s (ID: %d) registered with email %s",
                        event.getUsername(), event.getUserId(), event.getEmail())
        );
    }

    @RabbitListener(queues = RabbitMQConfig.EVENT_CREATED_QUEUE)
    public void handleEventCreated(EventCreatedEvent event) {
        logger.info("Received event.created event: {}", event);
        auditService.logEvent(
                "event.created",
                "Event Creation",
                String.format("Event '%s' (ID: %d) created at %s with capacity %d",
                        event.getEventName(), event.getEventId(), event.getLocation(), event.getCapacity())
        );
    }

    @RabbitListener(queues = RabbitMQConfig.BOOKING_SUCCEEDED_QUEUE)
    public void handleBookingSucceeded(BookingSucceededEvent event) {
        logger.info("Received booking.succeeded event: {}", event);
        auditService.logEvent(
                "booking.succeeded",
                "Booking Success",
                String.format("Booking ID: %d - User %d booked %d ticket(s) for event %d",
                        event.getBookingId(), event.getUserId(), event.getNumberOfTickets(), event.getEventId())
        );
    }
}
