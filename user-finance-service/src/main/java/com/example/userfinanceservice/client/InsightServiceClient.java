package com.example.userfinanceservice.client;

import com.example.userfinanceservice.entity.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.RestClientException;

import java.util.HashMap;
import java.util.Map;

@Service
public class InsightServiceClient {

    private static final Logger logger = LoggerFactory.getLogger(InsightServiceClient.class);

    @Autowired
    private RestTemplate restTemplate;

    @Value("${services.insight-service.url:http://localhost:8085}")
    private String insightServiceUrl;

    /**
     * Asynchronously notify Insight Service about new transaction
     * Executes in background thread pool, does not block caller
     */
    @Async("transactionAsyncExecutor")
    public void notifyTransactionCreatedAsync(Transaction transaction) {
        try {
            String url = insightServiceUrl + "/analytics";

            // Create analytics data from transaction
            Map<String, Object> analyticsData = new HashMap<>();
            analyticsData.put("userId", transaction.getUserId());
            analyticsData.put("categoryId", transaction.getCategory() != null ? transaction.getCategory().getId() : null);
            analyticsData.put("amount", transaction.getAmount());
            analyticsData.put("transactionType", transaction.getType().getValue());
            analyticsData.put("period", "MONTHLY");
            analyticsData.put("analyticsDate", transaction.getTransactionDate());

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(analyticsData, headers);

            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                url,
                HttpMethod.POST,
                request,
                new ParameterizedTypeReference<Map<String, Object>>() {}
            );

            if (response.getStatusCode().is2xxSuccessful()) {
                logger.info("Successfully notified Insight Service about transaction: {}", transaction.getId());
            }

        } catch (RestClientException e) {
            logger.warn("Failed to notify Insight Service about transaction (async): {}", e.getMessage());
        }
    }

    /**
     * Synchronously notify Insight Service about new transaction
     * Use for backward compatibility
     */
    public void notifyTransactionCreated(Transaction transaction) {
        try {
            String url = insightServiceUrl + "/analytics";

            // Create analytics data from transaction
            Map<String, Object> analyticsData = new HashMap<>();
            analyticsData.put("userId", transaction.getUserId());
            analyticsData.put("categoryId", transaction.getCategory() != null ? transaction.getCategory().getId() : null);
            analyticsData.put("amount", transaction.getAmount());
            analyticsData.put("transactionType", transaction.getType().getValue());
            analyticsData.put("period", "MONTHLY");
            analyticsData.put("analyticsDate", transaction.getTransactionDate());

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(analyticsData, headers);

            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                url,
                HttpMethod.POST,
                request,
                new ParameterizedTypeReference<Map<String, Object>>() {}
            );

            if (response.getStatusCode().is2xxSuccessful()) {
                logger.info("Successfully notified Insight Service about transaction: {}", transaction.getId());
            }

        } catch (RestClientException e) {
            logger.warn("Failed to notify Insight Service about transaction: {}", e.getMessage());
        }
    }

    /**
     * Asynchronously notify Insight Service about updated transaction
     */
    @Async("transactionAsyncExecutor")
    public void notifyTransactionUpdatedAsync(Transaction transaction) {
        notifyTransactionCreatedAsync(transaction);
    }

    public void notifyTransactionUpdated(Transaction transaction) {
        // For now, treat updates the same as creation
        notifyTransactionCreated(transaction);
    }

    /**
     * Asynchronously notify Insight Service about deleted transaction
     */
    @Async("transactionAsyncExecutor")
    public void notifyTransactionDeletedAsync(Long transactionId, Long userId) {
        try {
            logger.info("Async notification: Transaction {} deleted for user {}", transactionId, userId);
            // Note: This would require additional endpoint in Insight Service to handle deletions
            // Could implement analytics cleanup here if needed
        } catch (Exception e) {
            logger.warn("Failed to notify Insight Service about transaction deletion (async): {}", e.getMessage());
        }
    }

    public void notifyTransactionDeleted(Long transactionId, Long userId) {
        try {
            // Note: This would require additional endpoint in Insight Service to handle deletions
            logger.info("Transaction {} deleted for user {}", transactionId, userId);
            // Could implement analytics cleanup here if needed
        } catch (Exception e) {
            logger.warn("Failed to notify Insight Service about transaction deletion: {}", e.getMessage());
        }
    }

    public Map<String, Object> getUserInsights(Long userId) {
        try {
            String url = insightServiceUrl + "/analytics/user/" + userId + "/summary";

            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<Map<String, Object>>() {}
            );

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                return response.getBody();
            }

            return Map.of("success", false, "message", "Failed to fetch insights");
        } catch (RestClientException e) {
            System.err.println("Error calling Insight Service: " + e.getMessage());
            return Map.of("success", false, "message", "Service unavailable", "error", e.getMessage());
        }
    }
}