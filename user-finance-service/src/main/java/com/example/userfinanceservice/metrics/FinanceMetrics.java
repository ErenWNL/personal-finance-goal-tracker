package com.example.userfinanceservice.metrics;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * Custom business metrics for Finance Service
 */
@Component
public class FinanceMetrics {

    private final Counter transactionsCreated;
    private final Counter transactionsUpdated;
    private final Counter transactionsDeleted;
    private final Counter totalTransactionAmount;
    private final Timer transactionProcessingTime;

    @Autowired
    public FinanceMetrics(MeterRegistry meterRegistry) {
        this.transactionsCreated = Counter.builder("finance.transactions.created")
                .description("Total number of transactions created")
                .register(meterRegistry);

        this.transactionsUpdated = Counter.builder("finance.transactions.updated")
                .description("Total number of transactions updated")
                .register(meterRegistry);

        this.transactionsDeleted = Counter.builder("finance.transactions.deleted")
                .description("Total number of transactions deleted")
                .register(meterRegistry);

        this.totalTransactionAmount = Counter.builder("finance.transactions.total.amount")
                .description("Total amount of all transactions")
                .register(meterRegistry);

        this.transactionProcessingTime = Timer.builder("finance.transaction.processing.time")
                .description("Time taken to process a transaction")
                .register(meterRegistry);
    }

    /**
     * Increment transaction created counter
     */
    public void recordTransactionCreated() {
        transactionsCreated.increment();
    }

    /**
     * Increment transaction updated counter
     */
    public void recordTransactionUpdated() {
        transactionsUpdated.increment();
    }

    /**
     * Increment transaction deleted counter
     */
    public void recordTransactionDeleted() {
        transactionsDeleted.increment();
    }

    /**
     * Record transaction amount
     */
    public void recordTransactionAmount(double amount) {
        totalTransactionAmount.increment(amount);
    }

    /**
     * Record transaction processing time
     */
    public Timer.Sample recordTransactionProcessingStart() {
        return Timer.start();
    }

    public void recordTransactionProcessingStop(Timer.Sample sample) {
        sample.stop(transactionProcessingTime);
    }
}
