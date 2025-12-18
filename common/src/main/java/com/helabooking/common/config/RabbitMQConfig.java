package com.helabooking.common.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.amqp.core.*;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig {

    public static final String EXCHANGE_NAME = "helabooking.exchange";
    
    // Queue names - separate queues for each service to avoid competing consumers
    public static final String USER_REGISTERED_NOTIFICATION_QUEUE = "user.registered.notification.queue";
    public static final String USER_REGISTERED_AUDIT_QUEUE = "user.registered.audit.queue";
    
    public static final String EVENT_CREATED_NOTIFICATION_QUEUE = "event.created.notification.queue";
    public static final String EVENT_CREATED_AUDIT_QUEUE = "event.created.audit.queue";
    
    public static final String BOOKING_SUCCEEDED_TICKETING_QUEUE = "booking.succeeded.ticketing.queue";
    public static final String BOOKING_SUCCEEDED_NOTIFICATION_QUEUE = "booking.succeeded.notification.queue";
    public static final String BOOKING_SUCCEEDED_AUDIT_QUEUE = "booking.succeeded.audit.queue";
    
    // Routing keys
    public static final String USER_REGISTERED_KEY = "user.registered";
    public static final String EVENT_CREATED_KEY = "event.created";
    public static final String BOOKING_SUCCEEDED_KEY = "booking.succeeded";

    @Bean
    public TopicExchange exchange() {
        return new TopicExchange(EXCHANGE_NAME);
    }

    // User registered queues
    @Bean
    public Queue userRegisteredNotificationQueue() {
        return new Queue(USER_REGISTERED_NOTIFICATION_QUEUE, true);
    }

    @Bean
    public Queue userRegisteredAuditQueue() {
        return new Queue(USER_REGISTERED_AUDIT_QUEUE, true);
    }

    // Event created queues
    @Bean
    public Queue eventCreatedNotificationQueue() {
        return new Queue(EVENT_CREATED_NOTIFICATION_QUEUE, true);
    }

    @Bean
    public Queue eventCreatedAuditQueue() {
        return new Queue(EVENT_CREATED_AUDIT_QUEUE, true);
    }

    // Booking succeeded queues
    @Bean
    public Queue bookingSucceededTicketingQueue() {
        return new Queue(BOOKING_SUCCEEDED_TICKETING_QUEUE, true);
    }

    @Bean
    public Queue bookingSucceededNotificationQueue() {
        return new Queue(BOOKING_SUCCEEDED_NOTIFICATION_QUEUE, true);
    }

    @Bean
    public Queue bookingSucceededAuditQueue() {
        return new Queue(BOOKING_SUCCEEDED_AUDIT_QUEUE, true);
    }

    // Bindings - each queue gets the same routing key to receive all events
    @Bean
    public Binding userRegisteredNotificationBinding() {
        return BindingBuilder
                .bind(userRegisteredNotificationQueue())
                .to(exchange())
                .with(USER_REGISTERED_KEY);
    }

    @Bean
    public Binding userRegisteredAuditBinding() {
        return BindingBuilder
                .bind(userRegisteredAuditQueue())
                .to(exchange())
                .with(USER_REGISTERED_KEY);
    }

    @Bean
    public Binding eventCreatedNotificationBinding() {
        return BindingBuilder
                .bind(eventCreatedNotificationQueue())
                .to(exchange())
                .with(EVENT_CREATED_KEY);
    }

    @Bean
    public Binding eventCreatedAuditBinding() {
        return BindingBuilder
                .bind(eventCreatedAuditQueue())
                .to(exchange())
                .with(EVENT_CREATED_KEY);
    }

    @Bean
    public Binding bookingSucceededTicketingBinding() {
        return BindingBuilder
                .bind(bookingSucceededTicketingQueue())
                .to(exchange())
                .with(BOOKING_SUCCEEDED_KEY);
    }

    @Bean
    public Binding bookingSucceededNotificationBinding() {
        return BindingBuilder
                .bind(bookingSucceededNotificationQueue())
                .to(exchange())
                .with(BOOKING_SUCCEEDED_KEY);
    }

    @Bean
    public Binding bookingSucceededAuditBinding() {
        return BindingBuilder
                .bind(bookingSucceededAuditQueue())
                .to(exchange())
                .with(BOOKING_SUCCEEDED_KEY);
    }

    @Bean
    public ObjectMapper objectMapper() {
        ObjectMapper mapper = new ObjectMapper();
        mapper.registerModule(new JavaTimeModule());
        return mapper;
    }

    @Bean
    public MessageConverter messageConverter(ObjectMapper objectMapper) {
        return new Jackson2JsonMessageConverter(objectMapper);
    }

    @Bean
    public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory, MessageConverter messageConverter) {
        RabbitTemplate rabbitTemplate = new RabbitTemplate(connectionFactory);
        rabbitTemplate.setMessageConverter(messageConverter);
        return rabbitTemplate;
    }
}
