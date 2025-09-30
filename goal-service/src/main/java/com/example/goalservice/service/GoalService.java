package com.example.goalservice.service;

import com.example.goalservice.client.InsightServiceClient;
import com.example.goalservice.client.UserFinanceServiceClient;
import com.example.goalservice.dto.request.GoalRequest;
import com.example.goalservice.dto.response.GoalCategoryResponse;
import com.example.goalservice.dto.response.GoalResponse;
import com.example.goalservice.entity.Goal;
import com.example.goalservice.entity.GoalCategory;
import com.example.goalservice.repository.GoalCategoryRepository;
import com.example.goalservice.repository.GoalRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class GoalService {

    @Autowired
    private GoalRepository goalRepository;

    @Autowired
    private GoalCategoryRepository categoryRepository;

    @Autowired
    private InsightServiceClient insightServiceClient;

    @Autowired
    private UserFinanceServiceClient userFinanceServiceClient;

    public Map<String, Object> createGoal(GoalRequest request) {
        Map<String, Object> response = new HashMap<>();

        // Simple validation
        if (request.getUserId() == null) {
            response.put("success", false);
            response.put("message", "User ID is required");
            return response;
        }

        if (request.getTitle() == null || request.getTitle().trim().isEmpty()) {
            response.put("success", false);
            response.put("message", "Goal title is required");
            return response;
        }

        if (request.getTargetAmount() == null || request.getTargetAmount().compareTo(BigDecimal.ZERO) <= 0) {
            response.put("success", false);
            response.put("message", "Target amount must be greater than zero");
            return response;
        }

        if (request.getCategoryId() == null) {
            response.put("success", false);
            response.put("message", "Category is required");
            return response;
        }

        // Check if category exists
        Optional<GoalCategory> categoryOpt = categoryRepository.findById(request.getCategoryId());
        if (categoryOpt.isEmpty()) {
            response.put("success", false);
            response.put("message", "Category not found");
            return response;
        }

        // Create goal
        Goal goal = new Goal();
        goal.setUserId(request.getUserId());
        goal.setTitle(request.getTitle());
        goal.setDescription(request.getDescription());
        goal.setTargetAmount(request.getTargetAmount());
        goal.setCurrentAmount(request.getCurrentAmount() != null ? request.getCurrentAmount() : BigDecimal.ZERO);
        goal.setCategory(categoryOpt.get());
        goal.setPriorityLevel(request.getPriorityLevel() != null ? request.getPriorityLevel() : Goal.PriorityLevel.MEDIUM);
        goal.setTargetDate(request.getTargetDate());
        goal.setStartDate(request.getStartDate() != null ? request.getStartDate() : LocalDate.now());

        Goal savedGoal = goalRepository.save(goal);

        // Notify Insight Service about new goal
        try {
            insightServiceClient.notifyGoalCreated(savedGoal);
        } catch (Exception e) {
            System.err.println("Failed to notify Insight Service about goal creation: " + e.getMessage());
        }

        GoalResponse goalResponse = convertToGoalResponse(savedGoal);

        response.put("success", true);
        response.put("message", "Goal created successfully");
        response.put("goal", goalResponse);

        return response;
    }

    public Map<String, Object> getAllGoals() {
        Map<String, Object> response = new HashMap<>();

        List<Goal> goals = goalRepository.findAll();
        List<GoalResponse> goalResponses = goals.stream()
                .map(this::convertToGoalResponse)
                .toList();

        response.put("success", true);
        response.put("message", "Goals retrieved successfully");
        response.put("goals", goalResponses);
        response.put("count", goalResponses.size());

        return response;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getGoalsByUserId(Long userId) {
        Map<String, Object> response = new HashMap<>();

        List<Goal> allGoals = goalRepository.findAll();
        List<Goal> goals = allGoals.stream()
                .filter(goal -> goal.getUserId().equals(userId))
                .sorted((g1, g2) -> g2.getCreatedAt().compareTo(g1.getCreatedAt()))
                .toList();
        List<GoalResponse> goalResponses = goals.stream()
                .map(this::convertToGoalResponse)
                .toList();

        response.put("success", true);
        response.put("message", "User goals retrieved successfully");
        response.put("goals", goalResponses);
        response.put("count", goalResponses.size());

        return response;
    }

    @Transactional(readOnly = true)
    public GoalResponse getGoalById(Long id) {
        Optional<Goal> goalOpt = goalRepository.findById(id);
        return goalOpt.map(this::convertToGoalResponse).orElse(null);
    }

    public Map<String, Object> updateGoal(Long id, GoalRequest request) {
        Map<String, Object> response = new HashMap<>();

        Optional<Goal> goalOpt = goalRepository.findById(id);
        if (goalOpt.isEmpty()) {
            response.put("success", false);
            response.put("message", "Goal not found");
            return response;
        }

        Goal goal = goalOpt.get();

        // Update fields
        if (request.getTitle() != null) {
            goal.setTitle(request.getTitle());
        }
        if (request.getDescription() != null) {
            goal.setDescription(request.getDescription());
        }
        if (request.getTargetAmount() != null) {
            goal.setTargetAmount(request.getTargetAmount());
        }
        if (request.getCurrentAmount() != null) {
            goal.setCurrentAmount(request.getCurrentAmount());
        }
        if (request.getCategoryId() != null) {
            Optional<GoalCategory> categoryOpt = categoryRepository.findById(request.getCategoryId());
            if (categoryOpt.isPresent()) {
                goal.setCategory(categoryOpt.get());
            }
        }
        if (request.getPriorityLevel() != null) {
            goal.setPriorityLevel(request.getPriorityLevel());
        }
        if (request.getTargetDate() != null) {
            goal.setTargetDate(request.getTargetDate());
        }

        Goal updatedGoal = goalRepository.save(goal);

        // Check if goal is completed and notify accordingly
        try {
            if (updatedGoal.getCompletionPercentage().compareTo(BigDecimal.valueOf(100)) >= 0) {
                insightServiceClient.notifyGoalCompleted(updatedGoal);
            } else {
                insightServiceClient.notifyGoalUpdated(updatedGoal);
            }
        } catch (Exception e) {
            System.err.println("Failed to notify Insight Service about goal update: " + e.getMessage());
        }

        GoalResponse goalResponse = convertToGoalResponse(updatedGoal);

        response.put("success", true);
        response.put("message", "Goal updated successfully");
        response.put("goal", goalResponse);

        return response;
    }

    public Map<String, Object> deleteGoal(Long id) {
        Map<String, Object> response = new HashMap<>();

        Optional<Goal> goalOpt = goalRepository.findById(id);
        if (goalOpt.isEmpty()) {
            response.put("success", false);
            response.put("message", "Goal not found");
            return response;
        }

        Goal goal = goalOpt.get();
        String goalTitle = goal.getTitle();
        Long userId = goal.getUserId();

        goalRepository.deleteById(id);

        // Notify Insight Service about goal deletion
        try {
            insightServiceClient.notifyGoalDeleted(id, userId, goalTitle);
        } catch (Exception e) {
            System.err.println("Failed to notify Insight Service about goal deletion: " + e.getMessage());
        }

        response.put("success", true);
        response.put("message", "Goal deleted successfully");

        return response;
    }

    private GoalResponse convertToGoalResponse(Goal goal) {
        GoalResponse response = new GoalResponse();
        response.setId(goal.getId());
        response.setUserId(goal.getUserId());
        response.setTitle(goal.getTitle());
        response.setDescription(goal.getDescription());
        response.setTargetAmount(goal.getTargetAmount());
        response.setCurrentAmount(goal.getCurrentAmount());
        response.setPriorityLevel(goal.getPriorityLevel());
        response.setTargetDate(goal.getTargetDate());
        response.setStartDate(goal.getStartDate());
        response.setStatus(goal.getStatus());
        response.setCompletionPercentage(goal.getCompletionPercentage());
        response.setCreatedAt(goal.getCreatedAt());
        response.setUpdatedAt(goal.getUpdatedAt());

        // Convert category
        if (goal.getCategory() != null) {
            GoalCategoryResponse categoryResponse = new GoalCategoryResponse();
            categoryResponse.setId(goal.getCategory().getId());
            categoryResponse.setName(goal.getCategory().getName());
            categoryResponse.setDescription(goal.getCategory().getDescription());
            categoryResponse.setColorCode(goal.getCategory().getColorCode());
            categoryResponse.setCreatedAt(goal.getCategory().getCreatedAt());
            response.setCategory(categoryResponse);
        }

        return response;
    }
}
