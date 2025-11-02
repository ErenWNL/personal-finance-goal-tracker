package com.example.userfinanceservice.event;

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
