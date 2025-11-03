# Kafka Integration Guide
**Personal Finance Goal Tracker - Event Streaming & Message Queue**

---

## Overview

Apache Kafka will be used for:
- Event-driven notifications (transaction created, goal completed, etc.)
- Asynchronous processing (decouple insight generation from transactions)
- Real-time data pipeline (stream transactions to analytics)
- Audit trail (log all financial events)

---

## Architecture

```
Finance Service (Producer)
    ↓
    Topic: transactions.created
    Topic: transactions.updated
    ↓
Insight Service (Consumer) → Generate analytics
Notification Service (Consumer) → Send alerts
Audit Service (Consumer) → Log events
```

---

## Step 1: Add Kafka Dependencies

Add to each service's `pom.xml`:

```xml
<!-- Spring Kafka -->
<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
    <version>3.1.0</version>
</dependency>

<!-- Apache Kafka Client -->
<dependency>
    <groupId>org.apache.kafka</groupId>
    <artifactId>kafka-clients</artifactId>
    <version>3.5.0</version>
</dependency>
```

---

## Step 2: Create Kafka Configuration

Create file: `src/main/java/com/example/config/KafkaConfig.java`

```java
package com.example.config;

import org.apache.kafka.clients.admin.AdminClientConfig;
import org.apache.kafka.clients.admin.NewTopic;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.config.KafkaListenerContainerFactory;
import org.springframework.kafka.config.TopicBuilder;
import org.springframework.kafka.core.*;
import org.springframework.kafka.listener.ConcurrentMessageListenerContainer;
import org.springframework.kafka.support.serializer.JsonDeserializer;
import org.springframework.kafka.support.serializer.JsonSerializer;

import java.util.HashMap;
import java.util.Map;

/**
 * Kafka Configuration for event streaming
 */
@Configuration
@EnableKafka
public class KafkaConfig {

    @Value("${spring.kafka.bootstrap-servers:kafka:9092}")
    private String kafkaBootstrapServers;

    // =============================================
    // Kafka Admin Configuration
    // =============================================

    @Bean
    public KafkaAdmin admin() {
        Map<String, Object> configs = new HashMap<>();
        configs.put(AdminClientConfig.BOOTSTRAP_SERVERS_CONFIG, kafkaBootstrapServers);
        return new KafkaAdmin(configs);
    }

    // =============================================
    // Topic Definitions
    // =============================================

    @Bean
    public NewTopic transactionsCreatedTopic() {
        return TopicBuilder.name("transactions.created")
                .partitions(3)
                .replicas(1)
                .config("retention.ms", "604800000") // 7 days
                .build();
    }

    @Bean
    public NewTopic transactionsUpdatedTopic() {
        return TopicBuilder.name("transactions.updated")
                .partitions(3)
                .replicas(1)
                .config("retention.ms", "604800000")
                .build();
    }

    @Bean
    public NewTopic transactionsDeletedTopic() {
        return TopicBuilder.name("transactions.deleted")
                .partitions(1)
                .replicas(1)
                .config("retention.ms", "604800000")
                .build();
    }

    @Bean
    public NewTopic goalsCreatedTopic() {
        return TopicBuilder.name("goals.created")
                .partitions(1)
                .replicas(1)
                .config("retention.ms", "2592000000") // 30 days
                .build();
    }

    @Bean
    public NewTopic goalsCompletedTopic() {
        return TopicBuilder.name("goals.completed")
                .partitions(1)
                .replicas(1)
                .config("retention.ms", "2592000000")
                .build();
    }

    @Bean
    public NewTopic insightsGeneratedTopic() {
        return TopicBuilder.name("insights.generated")
                .partitions(2)
                .replicas(1)
                .config("retention.ms", "1209600000") // 14 days
                .build();
    }

    @Bean
    public NewTopic notificationsTopic() {
        return TopicBuilder.name("notifications.events")
                .partitions(1)
                .replicas(1)
                .config("retention.ms", "86400000") // 1 day
                .build();
    }

    @Bean
    public NewTopic auditTopic() {
        return TopicBuilder.name("audit.events")
                .partitions(1)
                .replicas(1)
                .config("retention.ms", "31536000000") // 1 year
                .build();
    }

    // =============================================
    // Producer Configuration
    // =============================================

    @Bean
    public ProducerFactory<String, String> producerFactory() {
        Map<String, Object> configProps = new HashMap<>();
        configProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, kafkaBootstrapServers);
        configProps.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        configProps.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, JsonSerializer.class);
        configProps.put(ProducerConfig.ACKS_CONFIG, "all");
        configProps.put(ProducerConfig.RETRIES_CONFIG, 3);
        configProps.put(ProducerConfig.LINGER_MS_CONFIG, 10);
        configProps.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "snappy");

        return new DefaultKafkaProducerFactory<>(configProps);
    }

    @Bean
    public KafkaTemplate<String, String> kafkaTemplate() {
        return new KafkaTemplate<>(producerFactory());
    }

    // =============================================
    // Consumer Configuration
    // =============================================

    @Bean
    public ConsumerFactory<String, String> consumerFactory() {
        Map<String, Object> configProps = new HashMap<>();
        configProps.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, kafkaBootstrapServers);
        configProps.put(ConsumerConfig.GROUP_ID_CONFIG, "personal-finance-group");
        configProps.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        configProps.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, JsonDeserializer.class);
        configProps.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        configProps.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, true);
        configProps.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, 500);
        configProps.put(JsonDeserializer.VALUE_DEFAULT_TYPE, String.class);
        configProps.put(JsonDeserializer.TRUSTED_PACKAGES, "*");

        return new DefaultKafkaConsumerFactory<>(configProps);
    }

    @Bean
    public KafkaListenerContainerFactory<ConcurrentMessageListenerContainer<String, String>>
    kafkaListenerContainerFactory() {
        ConcurrentKafkaListenerContainerFactory<String, String> factory =
                new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(consumerFactory());
        factory.setConcurrency(3);
        return factory;
    }
}
```

---

## Step 3: Create Event Classes

Create file: `src/main/java/com/example/event/TransactionEvent.java`

```java
package com.example.event;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Event published when a transaction is created/updated
 */
public class TransactionEvent implements Serializable {

    private Long transactionId;
    private Long userId;
    private String type;
    private String category;
    private String description;
    private BigDecimal amount;
    private LocalDateTime transactionDate;
    private LocalDateTime createdAt;
    private String eventType; // CREATED, UPDATED, DELETED

    // Constructors
    public TransactionEvent() {}

    public TransactionEvent(Long transactionId, Long userId, String type, String category,
                          String description, BigDecimal amount, LocalDateTime transactionDate,
                          LocalDateTime createdAt, String eventType) {
        this.transactionId = transactionId;
        this.userId = userId;
        this.type = type;
        this.category = category;
        this.description = description;
        this.amount = amount;
        this.transactionDate = transactionDate;
        this.createdAt = createdAt;
        this.eventType = eventType;
    }

    // Getters and setters
    public Long getTransactionId() { return transactionId; }
    public void setTransactionId(Long transactionId) { this.transactionId = transactionId; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public LocalDateTime getTransactionDate() { return transactionDate; }
    public void setTransactionDate(LocalDateTime transactionDate) { this.transactionDate = transactionDate; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getEventType() { return eventType; }
    public void setEventType(String eventType) { this.eventType = eventType; }
}
```

Create file: `src/main/java/com/example/event/GoalEvent.java`

```java
package com.example.event;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Event published when a goal is created/completed
 */
public class GoalEvent implements Serializable {

    private Long goalId;
    private Long userId;
    private String title;
    private String description;
    private BigDecimal targetAmount;
    private BigDecimal currentAmount;
    private LocalDateTime targetDate;
    private LocalDateTime completedDate;
    private String eventType; // CREATED, UPDATED, COMPLETED

    // Constructors
    public GoalEvent() {}

    public GoalEvent(Long goalId, Long userId, String title, String description,
                     BigDecimal targetAmount, BigDecimal currentAmount,
                     LocalDateTime targetDate, LocalDateTime completedDate, String eventType) {
        this.goalId = goalId;
        this.userId = userId;
        this.title = title;
        this.description = description;
        this.targetAmount = targetAmount;
        this.currentAmount = currentAmount;
        this.targetDate = targetDate;
        this.completedDate = completedDate;
        this.eventType = eventType;
    }

    // Getters and setters
    public Long getGoalId() { return goalId; }
    public void setGoalId(Long goalId) { this.goalId = goalId; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getTargetAmount() { return targetAmount; }
    public void setTargetAmount(BigDecimal targetAmount) { this.targetAmount = targetAmount; }

    public BigDecimal getCurrentAmount() { return currentAmount; }
    public void setCurrentAmount(BigDecimal currentAmount) { this.currentAmount = currentAmount; }

    public LocalDateTime getTargetDate() { return targetDate; }
    public void setTargetDate(LocalDateTime targetDate) { this.targetDate = targetDate; }

    public LocalDateTime getCompletedDate() { return completedDate; }
    public void setCompletedDate(LocalDateTime completedDate) { this.completedDate = completedDate; }

    public String getEventType() { return eventType; }
    public void setEventType(String eventType) { this.eventType = eventType; }
}
```

---

## Step 4: Create Event Producers

Create file: `src/main/java/com/example/event/TransactionEventProducer.java`

```java
package com.example.event;

import com.fasterxml.jackson.databind.ObjectMapper;
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
                    .setHeader(KafkaHeaders.MESSAGE_KEY, event.getUserId().toString())
                    .setHeader("eventType", eventType)
                    .setHeader("timestamp", System.currentTimeMillis())
                    .build();

            kafkaTemplate.send(message);
            logger.info("Published event to {}: {}", topic, event.getTransactionId());
        } catch (Exception e) {
            logger.error("Error publishing transaction event: {}", e.getMessage());
        }
    }
}
```

Create file: `src/main/java/com/example/event/GoalEventProducer.java`

```java
package com.example.event;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.Message;
import org.springframework.messaging.support.MessageBuilder;
import org.springframework.stereotype.Service;

/**
 * Produces goal events to Kafka
 */
@Service
public class GoalEventProducer {

    private static final Logger logger = LoggerFactory.getLogger(GoalEventProducer.class);
    private static final ObjectMapper objectMapper = new ObjectMapper();

    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;

    /**
     * Publish goal created event
     */
    public void publishGoalCreated(GoalEvent event) {
        publishEvent("goals.created", event, "CREATED");
    }

    /**
     * Publish goal completed event
     */
    public void publishGoalCompleted(GoalEvent event) {
        publishEvent("goals.completed", event, "COMPLETED");
    }

    /**
     * Generic event publisher
     */
    private void publishEvent(String topic, GoalEvent event, String eventType) {
        try {
            event.setEventType(eventType);
            String payload = objectMapper.writeValueAsString(event);

            Message<String> message = MessageBuilder
                    .withPayload(payload)
                    .setHeader(KafkaHeaders.TOPIC, topic)
                    .setHeader(KafkaHeaders.MESSAGE_KEY, event.getUserId().toString())
                    .setHeader("eventType", eventType)
                    .setHeader("timestamp", System.currentTimeMillis())
                    .build();

            kafkaTemplate.send(message);
            logger.info("Published event to {}: {}", topic, event.getGoalId());
        } catch (Exception e) {
            logger.error("Error publishing goal event: {}", e.getMessage());
        }
    }
}
```

---

## Step 5: Create Event Consumers

Create file: `src/main/java/com/example/event/TransactionEventListener.java`

```java
package com.example.event;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.annotation.TopicPartition;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Service;

/**
 * Listens to transaction events from Kafka
 * Use this in Insight Service, Notification Service, etc.
 */
@Service
public class TransactionEventListener {

    private static final Logger logger = LoggerFactory.getLogger(TransactionEventListener.class);
    private static final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Listen to transaction created events
     */
    @KafkaListener(
            topics = "transactions.created",
            groupId = "insight-service",
            containerFactory = "kafkaListenerContainerFactory"
    )
    public void handleTransactionCreated(
            @Payload String payload,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            @Header(KafkaHeaders.RECEIVED_PARTITION_ID) int partition) {
        try {
            TransactionEvent event = objectMapper.readValue(payload, TransactionEvent.class);
            logger.info("Received transaction.created event: {} from partition {}", event.getTransactionId(), partition);

            // Process the event
            // Example: Regenerate insights for the user
            // Example: Send notification to user
            // Example: Update analytics

        } catch (Exception e) {
            logger.error("Error processing transaction created event: {}", e.getMessage());
        }
    }

    /**
     * Listen to transaction updated events
     */
    @KafkaListener(
            topics = "transactions.updated",
            groupId = "insight-service",
            containerFactory = "kafkaListenerContainerFactory"
    )
    public void handleTransactionUpdated(@Payload String payload) {
        try {
            TransactionEvent event = objectMapper.readValue(payload, TransactionEvent.class);
            logger.info("Received transaction.updated event: {}", event.getTransactionId());

            // Process the event
        } catch (Exception e) {
            logger.error("Error processing transaction updated event: {}", e.getMessage());
        }
    }
}
```

Create file: `src/main/java/com/example/event/GoalEventListener.java`

```java
package com.example.event;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Service;

/**
 * Listens to goal events from Kafka
 */
@Service
public class GoalEventListener {

    private static final Logger logger = LoggerFactory.getLogger(GoalEventListener.class);
    private static final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Listen to goal completed events
     */
    @KafkaListener(
            topics = "goals.completed",
            groupId = "notification-service",
            containerFactory = "kafkaListenerContainerFactory"
    )
    public void handleGoalCompleted(
            @Payload String payload,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic) {
        try {
            GoalEvent event = objectMapper.readValue(payload, GoalEvent.class);
            logger.info("Received goal.completed event: {}", event.getGoalId());

            // Process the event
            // Example: Send congratulations email
            // Example: Award badge/achievement
            // Example: Create notification

        } catch (Exception e) {
            logger.error("Error processing goal completed event: {}", e.getMessage());
        }
    }
}
```

---

## Step 6: Publish Events from Services

### Finance Service - Transaction Creation

```java
@Service
public class TransactionService {

    @Autowired
    private TransactionRepository transactionRepository;

    @Autowired
    private TransactionEventProducer eventProducer;

    @Transactional
    public Transaction createTransaction(Transaction transaction) {
        Transaction saved = transactionRepository.save(transaction);

        // Publish event
        TransactionEvent event = new TransactionEvent(
                saved.getId(),
                saved.getUser().getId(),
                saved.getType(),
                saved.getCategory(),
                saved.getDescription(),
                saved.getAmount(),
                saved.getTransactionDate(),
                saved.getCreatedAt(),
                "CREATED"
        );
        eventProducer.publishTransactionCreated(event);

        return saved;
    }
}
```

### Goal Service - Goal Completion

```java
@Service
public class GoalService {

    @Autowired
    private GoalRepository goalRepository;

    @Autowired
    private GoalEventProducer eventProducer;

    @Transactional
    public Goal completeGoal(Long goalId) {
        Goal goal = goalRepository.findById(goalId)
                .orElseThrow(() -> new NotFoundException("Goal not found"));

        goal.setStatus("COMPLETED");
        goal.setCompletedDate(LocalDateTime.now());
        Goal saved = goalRepository.save(goal);

        // Publish event
        GoalEvent event = new GoalEvent(
                saved.getId(),
                saved.getUser().getId(),
                saved.getTitle(),
                saved.getDescription(),
                saved.getTargetAmount(),
                saved.getCurrentAmount(),
                saved.getTargetDate(),
                saved.getCompletedDate(),
                "COMPLETED"
        );
        eventProducer.publishGoalCompleted(event);

        return saved;
    }
}
```

---

## Step 7: Update application.properties

```properties
# Kafka Configuration
spring.kafka.bootstrap-servers=kafka:9092
spring.kafka.producer.key-serializer=org.apache.kafka.common.serialization.StringSerializer
spring.kafka.producer.value-serializer=org.springframework.kafka.support.serializer.JsonSerializer
spring.kafka.consumer.key-deserializer=org.apache.kafka.common.serialization.StringDeserializer
spring.kafka.consumer.value-deserializer=org.springframework.kafka.support.serializer.JsonDeserializer
spring.kafka.consumer.group-id=personal-finance-group
spring.kafka.consumer.auto-offset-reset=earliest
```

---

## Kafka UI Access

**URL**: http://localhost:8000

View all topics, messages, consumer groups, and monitor Kafka health.

---

## Monitoring Kafka with Prometheus

Kafka metrics are automatically exported to Prometheus. Monitor:
- Topic throughput
- Consumer lag
- Producer error rate
- Broker health

---

## Best Practices

1. **Key Selection**: Use `userId` as key to maintain ordering per user
2. **Partitioning**: More partitions = higher throughput but higher latency
3. **Retention**: Set appropriate retention based on use case
4. **Compression**: Use snappy compression for network efficiency
5. **Error Handling**: Implement error handling and dead letter topics
6. **Monitoring**: Monitor consumer lag and processing time

---

## Next Steps

1. Deploy Kafka with Docker Compose
2. Add Kafka dependencies to microservices
3. Implement event producers and consumers
4. Set up event listeners in relevant services
5. Monitor Kafka health and performance

