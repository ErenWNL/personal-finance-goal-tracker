package com.example.insightservice.client;

import com.example.insightservice.dto.external.TransactionDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.RestClientException;

import java.util.List;
import java.util.Map;

@Service
public class UserFinanceServiceClient {

    @Autowired
    private RestTemplate restTemplate;

    @Value("${services.user-finance.url:http://localhost:8082}")
    private String userFinanceServiceUrl;

    public List<TransactionDto> getUserTransactions(Long userId) {
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
                    List<Map<String, Object>> transactionMaps = (List<Map<String, Object>>) responseBody.get("transactions");

                    return transactionMaps.stream()
                        .map(this::mapToTransactionDto)
                        .toList();
                }
            }

            return List.of();
        } catch (RestClientException e) {
            System.err.println("Error calling User Finance Service: " + e.getMessage());
            return List.of();
        }
    }

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
            System.err.println("Error calling User Finance Service for summary: " + e.getMessage());
            return Map.of("success", false, "message", "Service unavailable", "error", e.getMessage());
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

    private TransactionDto mapToTransactionDto(Map<String, Object> transactionMap) {
        TransactionDto dto = new TransactionDto();

        if (transactionMap.get("id") != null) {
            dto.setId(Long.valueOf(transactionMap.get("id").toString()));
        }
        if (transactionMap.get("userId") != null) {
            dto.setUserId(Long.valueOf(transactionMap.get("userId").toString()));
        }
        if (transactionMap.get("categoryId") != null) {
            dto.setCategoryId(Long.valueOf(transactionMap.get("categoryId").toString()));
        }
        if (transactionMap.get("goalId") != null) {
            dto.setGoalId(Long.valueOf(transactionMap.get("goalId").toString()));
        }
        if (transactionMap.get("amount") != null) {
            dto.setAmount(new java.math.BigDecimal(transactionMap.get("amount").toString()));
        }
        if (transactionMap.get("type") != null) {
            dto.setType(transactionMap.get("type").toString());
        }
        if (transactionMap.get("description") != null) {
            dto.setDescription(transactionMap.get("description").toString());
        }

        return dto;
    }
}