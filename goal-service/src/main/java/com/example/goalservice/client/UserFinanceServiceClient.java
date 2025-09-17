package com.example.goalservice.client;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.RestClientException;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Service
public class UserFinanceServiceClient {

    @Autowired
    private RestTemplate restTemplate;

    @Value("${services.user-finance.url:http://localhost:8082}")
    private String userFinanceServiceUrl;

    public Map<String, Object> getUserTransactionSummary(Long userId) {
        try {
            String url = userFinanceServiceUrl + "/finance/transactions/user/" + userId + "/summary";

            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<Map<String, Object>>() {}
            );

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                return response.getBody();
            }

            return Map.of("success", false, "message", "Failed to fetch transaction summary");
        } catch (RestClientException e) {
            System.err.println("Error calling User Finance Service: " + e.getMessage());
            return Map.of("success", false, "message", "Service unavailable", "error", e.getMessage());
        }
    }

    public List<Map<String, Object>> getUserTransactions(Long userId) {
        try {
            String url = userFinanceServiceUrl + "/finance/transactions/user/" + userId;

            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<Map<String, Object>>() {}
            );

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                Map<String, Object> responseBody = response.getBody();

                if (responseBody.get("transactions") instanceof List) {
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> transactions = (List<Map<String, Object>>) responseBody.get("transactions");
                    return transactions;
                }
            }

            return List.of();
        } catch (RestClientException e) {
            System.err.println("Error calling User Finance Service for transactions: " + e.getMessage());
            return List.of();
        }
    }

    public BigDecimal calculateGoalContributions(Long userId, Long goalId) {
        try {
            List<Map<String, Object>> transactions = getUserTransactions(userId);

            return transactions.stream()
                .filter(t -> {
                    Object transactionGoalId = t.get("goalId");
                    return transactionGoalId != null &&
                           goalId.equals(Long.valueOf(transactionGoalId.toString()));
                })
                .filter(t -> "INCOME".equals(t.get("type")))
                .map(t -> new BigDecimal(t.get("amount").toString()))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        } catch (Exception e) {
            System.err.println("Error calculating goal contributions: " + e.getMessage());
            return BigDecimal.ZERO;
        }
    }

    public List<Map<String, Object>> getAllCategories() {
        try {
            String url = userFinanceServiceUrl + "/finance/categories";

            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<Map<String, Object>>() {}
            );

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                Map<String, Object> responseBody = response.getBody();

                if (responseBody.get("categories") instanceof List) {
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> categories = (List<Map<String, Object>>) responseBody.get("categories");
                    return categories;
                }
            }

            return List.of();
        } catch (RestClientException e) {
            System.err.println("Error calling User Finance Service for categories: " + e.getMessage());
            return List.of();
        }
    }
}