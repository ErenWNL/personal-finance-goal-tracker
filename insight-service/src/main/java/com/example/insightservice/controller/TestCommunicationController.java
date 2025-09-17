package com.example.insightservice.controller;

import com.example.insightservice.client.GoalServiceClient;
import com.example.insightservice.client.UserFinanceServiceClient;
import com.example.insightservice.dto.external.GoalDto;
import com.example.insightservice.dto.external.TransactionDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/test")
public class TestCommunicationController {

    @Autowired
    private UserFinanceServiceClient userFinanceClient;

    @Autowired
    private GoalServiceClient goalServiceClient;

    @GetMapping("/communication-status")
    public ResponseEntity<Map<String, Object>> testCommunicationStatus() {
        Map<String, Object> response = new HashMap<>();

        // Test User Finance Service communication
        Map<String, Object> userFinanceStatus = new HashMap<>();
        try {
            List<Map<String, Object>> categories = userFinanceClient.getAllCategories();
            userFinanceStatus.put("status", "SUCCESS");
            userFinanceStatus.put("message", "Successfully connected to User Finance Service");
            userFinanceStatus.put("categoriesCount", categories.size());
        } catch (Exception e) {
            userFinanceStatus.put("status", "FAILED");
            userFinanceStatus.put("message", "Failed to connect to User Finance Service: " + e.getMessage());
        }

        // Test Goal Service communication
        Map<String, Object> goalServiceStatus = new HashMap<>();
        try {
            List<Map<String, Object>> goalCategories = goalServiceClient.getAllGoalCategories();
            goalServiceStatus.put("status", "SUCCESS");
            goalServiceStatus.put("message", "Successfully connected to Goal Service");
            goalServiceStatus.put("goalCategoriesCount", goalCategories.size());
        } catch (Exception e) {
            goalServiceStatus.put("status", "FAILED");
            goalServiceStatus.put("message", "Failed to connect to Goal Service: " + e.getMessage());
        }

        response.put("insightService", "RUNNING");
        response.put("userFinanceService", userFinanceStatus);
        response.put("goalService", goalServiceStatus);
        response.put("timestamp", java.time.LocalDateTime.now());

        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/test-integration")
    public ResponseEntity<Map<String, Object>> testUserIntegration(@PathVariable Long userId) {
        Map<String, Object> response = new HashMap<>();

        try {
            // Test fetching user transactions
            List<TransactionDto> transactions = userFinanceClient.getUserTransactions(userId);

            // Test fetching user goals
            List<GoalDto> goals = goalServiceClient.getUserGoals(userId);

            // Test fetching transaction summary
            Map<String, Object> transactionSummary = userFinanceClient.getUserTransactionSummary(userId);

            response.put("success", true);
            response.put("userId", userId);
            response.put("transactionsCount", transactions.size());
            response.put("goalsCount", goals.size());
            response.put("transactionSummary", transactionSummary);
            response.put("message", "Integration test successful");

            // Sample data check
            if (!transactions.isEmpty()) {
                response.put("sampleTransaction", transactions.get(0));
            }
            if (!goals.isEmpty()) {
                response.put("sampleGoal", goals.get(0));
            }

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Integration test failed: " + e.getMessage());
            response.put("error", e.getClass().getSimpleName());
        }

        return ResponseEntity.ok(response);
    }

    @GetMapping("/service-urls")
    public ResponseEntity<Map<String, Object>> getServiceUrls() {
        Map<String, Object> response = new HashMap<>();

        response.put("userFinanceServiceUrl", "http://localhost:8082");
        response.put("goalServiceUrl", "http://localhost:8083");
        response.put("insightServiceUrl", "http://localhost:8085");
        response.put("authServiceUrl", "http://localhost:8081");
        response.put("eurekaServerUrl", "http://localhost:8761");
        response.put("apiGatewayUrl", "http://localhost:8080");

        return ResponseEntity.ok(response);
    }

    @PostMapping("/simulate-transaction-event")
    public ResponseEntity<Map<String, Object>> simulateTransactionEvent(@RequestBody Map<String, Object> eventData) {
        Map<String, Object> response = new HashMap<>();

        try {
            // This endpoint simulates receiving a transaction event from User Finance Service
            response.put("success", true);
            response.put("message", "Transaction event processed successfully");
            response.put("eventData", eventData);
            response.put("processedAt", java.time.LocalDateTime.now());

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Failed to process transaction event: " + e.getMessage());
        }

        return ResponseEntity.ok(response);
    }

    @PostMapping("/simulate-goal-event")
    public ResponseEntity<Map<String, Object>> simulateGoalEvent(@RequestBody Map<String, Object> eventData) {
        Map<String, Object> response = new HashMap<>();

        try {
            // This endpoint simulates receiving a goal event from Goal Service
            response.put("success", true);
            response.put("message", "Goal event processed successfully");
            response.put("eventData", eventData);
            response.put("processedAt", java.time.LocalDateTime.now());

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Failed to process goal event: " + e.getMessage());
        }

        return ResponseEntity.ok(response);
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Test Communication Controller is running!");
    }
}