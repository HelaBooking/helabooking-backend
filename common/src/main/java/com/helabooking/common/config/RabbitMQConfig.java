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
    
    // Queue names
    public static final String USER_REGISTERED_QUEUE = "user.registered.queue";
    public static final String EVENT_CREATED_QUEUE = "event.created.queue";
    public static final String BOOKING_SUCCEEDED_QUEUE = "booking.succeeded.queue";
    
    // Routing keys
    public static final String USER_REGISTERED_KEY = "user.registered";
    public static final String EVENT_CREATED_KEY = "event.created";
    public static final String BOOKING_SUCCEEDED_KEY = "booking.succeeded";

    @Bean
    public TopicExchange exchange() {
        return new TopicExchange(EXCHANGE_NAME);
    }

    @Bean
    public Queue userRegisteredQueue() {
        return new Queue(USER_REGISTERED_QUEUE, true);
    }

    @Bean
    public Queue eventCreatedQueue() {
        return new Queue(EVENT_CREATED_QUEUE, true);
    }

    @Bean
    public Queue bookingSucceededQueue() {
        return new Queue(BOOKING_SUCCEEDED_QUEUE, true);
    }

    @Bean
    public Binding userRegisteredBinding() {
        return BindingBuilder
                .bind(userRegisteredQueue())
                .to(exchange())
                .with(USER_REGISTERED_KEY);
    }

    @Bean
    public Binding eventCreatedBinding() {
        return BindingBuilder
                .bind(eventCreatedQueue())
                .to(exchange())
                .with(EVENT_CREATED_KEY);
    }

    @Bean
    public Binding bookingSucceededBinding() {
        return BindingBuilder
                .bind(bookingSucceededQueue())
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
