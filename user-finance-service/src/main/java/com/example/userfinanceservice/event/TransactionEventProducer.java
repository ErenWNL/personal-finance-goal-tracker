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
import org.springframework.scheduling.annotation.Async;
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
     * Asynchronously publish transaction created event
     * Executes in background thread pool, does not block caller
     */
    @Async("transactionAsyncExecutor")
    public void publishTransactionCreatedAsync(TransactionEvent event) {
        publishEventAsync("transactions.created", event, "CREATED");
    }

    /**
     * Synchronously publish transaction created event
     * For backward compatibility
     */
    public void publishTransactionCreated(TransactionEvent event) {
        publishEvent("transactions.created", event, "CREATED");
    }

    /**
     * Asynchronously publish transaction updated event
     */
    @Async("transactionAsyncExecutor")
    public void publishTransactionUpdatedAsync(TransactionEvent event) {
        publishEventAsync("transactions.updated", event, "UPDATED");
    }

    /**
     * Publish transaction updated event
     */
    public void publishTransactionUpdated(TransactionEvent event) {
        publishEvent("transactions.updated", event, "UPDATED");
    }

    /**
     * Asynchronously publish transaction deleted event
     */
    @Async("transactionAsyncExecutor")
    public void publishTransactionDeletedAsync(TransactionEvent event) {
        publishEventAsync("transactions.deleted", event, "DELETED");
    }

    /**
     * Publish transaction deleted event
     */
    public void publishTransactionDeleted(TransactionEvent event) {
        publishEvent("transactions.deleted", event, "DELETED");
    }

    /**
     * Generic async event publisher
     */
    private void publishEventAsync(String topic, TransactionEvent event, String eventType) {
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
            logger.info("Published async event to {}: {}", topic, event.getTransactionId());
        } catch (Exception e) {
            logger.warn("Error publishing transaction event (async): {}", e.getMessage());
        }
    }

    /**
     * Generic synchronous event publisher
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
