package com.example.userfinanceservice.event;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.Message;
import org.springframework.messaging.support.MessageBuilder;
import org.springframework.stereotype.Service;

/**
 * Produces transaction events to Kafka
 */
@Service
public class TransactionEventProducer {

    private static final Logger logger = LoggerFactory.getLogger(TransactionEventProducer.class);
    private static final ObjectMapper objectMapper = new ObjectMapper();

    static {
        objectMapper.registerModule(new JavaTimeModule());
    }

    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;

    /**
     * Publish transaction created event
     */
    public void publishTransactionCreated(TransactionEvent event) {
        publishEvent("transactions.created", event, "CREATED");
    }

    /**
     * Publish transaction updated event
     */
    public void publishTransactionUpdated(TransactionEvent event) {
        publishEvent("transactions.updated", event, "UPDATED");
    }

    /**
     * Publish transaction deleted event
     */
    public void publishTransactionDeleted(TransactionEvent event) {
        publishEvent("transactions.deleted", event, "DELETED");
    }

    /**
     * Generic event publisher
     */
    private void publishEvent(String topic, TransactionEvent event, String eventType) {
        try {
            event.setEventType(eventType);
            String payload = objectMapper.writeValueAsString(event);

            Message<String> message = MessageBuilder
                    .withPayload(payload)
                    .setHeader(KafkaHeaders.TOPIC, topic)
                    .setHeader("kafka_messageKey", event.getUserId().toString())
                    .setHeader("eventType", eventType)
                    .setHeader("customTimestamp", System.currentTimeMillis())
                    .build();

            kafkaTemplate.send(message);
            logger.info("Published event to {}: {}", topic, event.getTransactionId());
        } catch (Exception e) {
            logger.error("Error publishing transaction event: {}", e.getMessage());
        }
    }
}
