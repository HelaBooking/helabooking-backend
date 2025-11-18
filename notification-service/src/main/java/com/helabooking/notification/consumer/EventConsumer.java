package com.helabooking.notification.consumer;

import com.helabooking.common.config.RabbitMQConfig;
import com.helabooking.common.event.UserRegisteredEvent;
import com.helabooking.common.event.EventCreatedEvent;
import com.helabooking.common.event.BookingSucceededEvent;
import com.helabooking.notification.service.NotificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class EventConsumer {

    private static final Logger logger = LoggerFactory.getLogger(EventConsumer.class);

    @Autowired
    private NotificationService notificationService;

    @RabbitListener(queues = RabbitMQConfig.USER_REGISTERED_QUEUE)
    public void handleUserRegistered(UserRegisteredEvent event) {
        logger.info("Received user.registered event: {}", event);
        notificationService.sendNotification(
                event.getEmail(),
                "Welcome to HelaBooking",
                "Welcome " + event.getUsername() + "! Your account has been created successfully.",
                "EMAIL"
        );
    }

    @RabbitListener(queues = RabbitMQConfig.EVENT_CREATED_QUEUE)
    public void handleEventCreated(EventCreatedEvent event) {
        logger.info("Received event.created event: {}", event);
        notificationService.sendNotification(
                "admin@helabooking.com",
                "New Event Created",
                "A new event '" + event.getEventName() + "' has been created at " + event.getLocation(),
                "EMAIL"
        );
    }

    @RabbitListener(queues = RabbitMQConfig.NOTIFICATION_BOOKING_QUEUE)
    public void handleBookingSucceeded(BookingSucceededEvent event) {
        logger.info("Received booking.succeeded event: {}", event);
        notificationService.sendNotification(
                "user-" + event.getUserId() + "@helabooking.com",
                "Booking Confirmed",
                "Your booking for " + event.getNumberOfTickets() + " ticket(s) has been confirmed. Booking ID: " + event.getBookingId(),
                "EMAIL"
        );
    }
}
