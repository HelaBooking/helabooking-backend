package com.helabooking.notification.service;

import com.helabooking.notification.model.Notification;
import com.helabooking.notification.repository.NotificationRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class NotificationService {

    private static final Logger logger = LoggerFactory.getLogger(NotificationService.class);

    @Autowired
    private NotificationRepository notificationRepository;

    public void sendNotification(String recipient, String subject, String message, String type) {
        Notification notification = new Notification();
        notification.setRecipient(recipient);
        notification.setSubject(subject);
        notification.setMessage(message);
        notification.setType(type);
        notification.setStatus("SENT");

        notificationRepository.save(notification);
        logger.info("Notification sent to {}: {}", recipient, subject);
    }
}
