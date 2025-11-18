package com.helabooking.ticketing.consumer;

import com.helabooking.common.config.RabbitMQConfig;
import com.helabooking.common.event.BookingSucceededEvent;
import com.helabooking.ticketing.service.TicketingService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class BookingSucceededConsumer {

    private static final Logger logger = LoggerFactory.getLogger(BookingSucceededConsumer.class);

    @Autowired
    private TicketingService ticketingService;

    @RabbitListener(queues = RabbitMQConfig.TICKETING_BOOKING_QUEUE)
    public void handleBookingSucceeded(BookingSucceededEvent event) {
        logger.info("Received booking.succeeded event: {}", event);
        ticketingService.generateTickets(
                event.getBookingId(),
                event.getUserId(),
                event.getEventId(),
                event.getNumberOfTickets()
        );
        logger.info("Generated {} tickets for booking {}", event.getNumberOfTickets(), event.getBookingId());
    }
}
