package com.example.goalservice.client;

import com.example.goalservice.entity.Goal;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.RestClientException;

import java.util.HashMap;
import java.util.Map;

@Service
public class InsightServiceClient {

    @Autowired
    private RestTemplate restTemplate;

    @Value("${services.insight-service.url:http://localhost:8085}")
    private String insightServiceUrl;

    public void notifyGoalCreated(Goal goal) {
        try {
            String url = insightServiceUrl + "/notifications";

            // Create notification data for goal creation
            Map<String, Object> notificationData = new HashMap<>();
            notificationData.put("userId", goal.getUserId());
            notificationData.put("notificationType", "GOAL_CREATED");
            notificationData.put("title", "New Goal Created");
            notificationData.put("message", "Goal '" + goal.getTitle() + "' has been created with target amount: $" + goal.getTargetAmount());
            notificationData.put("relatedGoalId", goal.getId());
            notificationData.put("isRead", false);
            notificationData.put("priority", goal.getPriorityLevel().toString());

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(notificationData, headers);

            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                url,
                HttpMethod.POST,
                request,
                new ParameterizedTypeReference<Map<String, Object>>() {}
            );

            if (response.getStatusCode().is2xxSuccessful()) {
                System.out.println("Successfully notified Insight Service about goal creation: " + goal.getId());
            }

        } catch (RestClientException e) {
            System.err.println("Failed to notify Insight Service about goal creation: " + e.getMessage());
        }
    }

    public void notifyGoalUpdated(Goal goal) {
        try {
            String url = insightServiceUrl + "/notifications";

            // Create notification data for goal update
            Map<String, Object> notificationData = new HashMap<>();
            notificationData.put("userId", goal.getUserId());
            notificationData.put("notificationType", "GOAL_UPDATED");
            notificationData.put("title", "Goal Updated");
            notificationData.put("message", "Goal '" + goal.getTitle() + "' has been updated. Current progress: $" + goal.getCurrentAmount() + " of $" + goal.getTargetAmount());
            notificationData.put("relatedGoalId", goal.getId());
            notificationData.put("isRead", false);
            notificationData.put("priority", "MEDIUM");

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(notificationData, headers);

            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                url,
                HttpMethod.POST,
                request,
                new ParameterizedTypeReference<Map<String, Object>>() {}
            );

            if (response.getStatusCode().is2xxSuccessful()) {
                System.out.println("Successfully notified Insight Service about goal update: " + goal.getId());
            }

        } catch (RestClientException e) {
            System.err.println("Failed to notify Insight Service about goal update: " + e.getMessage());
        }
    }

    public void notifyGoalCompleted(Goal goal) {
        try {
            String url = insightServiceUrl + "/notifications";

            // Create notification data for goal completion
            Map<String, Object> notificationData = new HashMap<>();
            notificationData.put("userId", goal.getUserId());
            notificationData.put("notificationType", "GOAL_COMPLETED");
            notificationData.put("title", "Goal Completed!");
            notificationData.put("message", "Congratulations! You've completed your goal '" + goal.getTitle() + "' with a target of $" + goal.getTargetAmount());
            notificationData.put("relatedGoalId", goal.getId());
            notificationData.put("isRead", false);
            notificationData.put("priority", "HIGH");

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(notificationData, headers);

            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                url,
                HttpMethod.POST,
                request,
                new ParameterizedTypeReference<Map<String, Object>>() {}
            );

            if (response.getStatusCode().is2xxSuccessful()) {
                System.out.println("Successfully notified Insight Service about goal completion: " + goal.getId());
            }

        } catch (RestClientException e) {
            System.err.println("Failed to notify Insight Service about goal completion: " + e.getMessage());
        }
    }

    public void notifyGoalDeleted(Long goalId, Long userId, String goalName) {
        try {
            String url = insightServiceUrl + "/notifications";

            // Create notification data for goal deletion
            Map<String, Object> notificationData = new HashMap<>();
            notificationData.put("userId", userId);
            notificationData.put("notificationType", "GOAL_DELETED");
            notificationData.put("title", "Goal Deleted");
            notificationData.put("message", "Goal '" + goalName + "' has been deleted");
            notificationData.put("relatedGoalId", goalId);
            notificationData.put("isRead", false);
            notificationData.put("priority", "LOW");

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(notificationData, headers);

            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                url,
                HttpMethod.POST,
                request,
                new ParameterizedTypeReference<Map<String, Object>>() {}
            );

            if (response.getStatusCode().is2xxSuccessful()) {
                System.out.println("Successfully notified Insight Service about goal deletion: " + goalId);
            }

        } catch (RestClientException e) {
            System.err.println("Failed to notify Insight Service about goal deletion: " + e.getMessage());
        }
    }

    public Map<String, Object> getUserGoalInsights(Long userId) {
        try {
            String url = insightServiceUrl + "/integrated/user/" + userId + "/goal-progress-analysis";

            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<Map<String, Object>>() {}
            );

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                return response.getBody();
            }

            return Map.of("success", false, "message", "Failed to fetch goal insights");
        } catch (RestClientException e) {
            System.err.println("Error calling Insight Service for goal insights: " + e.getMessage());
            return Map.of("success", false, "message", "Service unavailable", "error", e.getMessage());
        }
    }
}