package com.helabooking.booking.client;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class EventServiceClient {

    @Autowired
    private RestTemplate restTemplate;

    @Value("${event.service.url:http://localhost:8082}")
    private String eventServiceUrl;

    public boolean reserveSeats(Long eventId, Integer numberOfSeats) {
        try {
            String url = eventServiceUrl + "/api/events/" + eventId + "/reserve?seats=" + numberOfSeats;
            Boolean result = restTemplate.postForObject(url, null, Boolean.class);
            return result != null && result;
        } catch (Exception e) {
            return false;
        }
    }
}
