package com.example.insightservice.client;

import com.example.insightservice.dto.external.GoalDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.RestClientException;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
public class GoalServiceClient {

    @Autowired
    private RestTemplate restTemplate;

    @Value("${services.goal-service.url:http://localhost:8083}")
    private String goalServiceUrl;

    public List<GoalDto> getUserGoals(Long userId) {
        try {
            String url = goalServiceUrl + "/goals/user/" + userId;

            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<Map<String, Object>>() {}
            );

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                Map<String, Object> responseBody = response.getBody();

                if (responseBody.get("goals") instanceof List) {
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> goalMaps = (List<Map<String, Object>>) responseBody.get("goals");

                    return goalMaps.stream()
                        .map(this::mapToGoalDto)
                        .toList();
                }
            }

            return List.of();
        } catch (RestClientException e) {
            System.err.println("Error calling Goal Service: " + e.getMessage());
            return List.of();
        }
    }

    public GoalDto getGoalById(Long goalId) {
        try {
            String url = goalServiceUrl + "/goals/" + goalId;

            ResponseEntity<GoalDto> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                null,
                GoalDto.class
            );

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                return response.getBody();
            }

            return null;
        } catch (RestClientException e) {
            System.err.println("Error calling Goal Service for goal " + goalId + ": " + e.getMessage());
            return null;
        }
    }

    public List<Map<String, Object>> getAllGoalCategories() {
        try {
            String url = goalServiceUrl + "/api/goal-categories";

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
            System.err.println("Error calling Goal Service for categories: " + e.getMessage());
            return List.of();
        }
    }

    private GoalDto mapToGoalDto(Map<String, Object> goalMap) {
        GoalDto dto = new GoalDto();

        if (goalMap.get("id") != null) {
            dto.setId(Long.valueOf(goalMap.get("id").toString()));
        }
        if (goalMap.get("userId") != null) {
            dto.setUserId(Long.valueOf(goalMap.get("userId").toString()));
        }
        if (goalMap.get("categoryId") != null) {
            dto.setCategoryId(Long.valueOf(goalMap.get("categoryId").toString()));
        }
        if (goalMap.get("name") != null) {
            dto.setName(goalMap.get("name").toString());
        }
        if (goalMap.get("description") != null) {
            dto.setDescription(goalMap.get("description").toString());
        }
        if (goalMap.get("targetAmount") != null) {
            dto.setTargetAmount(new java.math.BigDecimal(goalMap.get("targetAmount").toString()));
        }
        if (goalMap.get("currentAmount") != null) {
            dto.setCurrentAmount(new java.math.BigDecimal(goalMap.get("currentAmount").toString()));
        }
        if (goalMap.get("targetDate") != null) {
            dto.setTargetDate(LocalDate.parse(goalMap.get("targetDate").toString()));
        }
        if (goalMap.get("status") != null) {
            dto.setStatus(goalMap.get("status").toString());
        }
        if (goalMap.get("priority") != null) {
            dto.setPriority(goalMap.get("priority").toString());
        }
        if (goalMap.get("createdAt") != null) {
            dto.setCreatedAt(LocalDateTime.parse(goalMap.get("createdAt").toString()));
        }

        return dto;
    }
}