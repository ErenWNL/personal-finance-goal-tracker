package com.example.insightservice.controller;

import com.example.insightservice.entity.UserRecommendation;
import com.example.insightservice.service.RecommendationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/recommendations")
@Tag(name = "Recommendations", description = "Personalized recommendations endpoints")
public class RecommendationController {

    @Autowired
    private RecommendationService recommendationService;

    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> getUserRecommendations(@PathVariable Long userId) {
        List<UserRecommendation> recommendations = recommendationService.getActiveRecommendations(userId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("recommendations", recommendations);
        response.put("count", recommendations.size());
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/summary")
    public ResponseEntity<Map<String, Object>> getRecommendationSummary(@PathVariable Long userId) {
        Map<String, Object> summary = recommendationService.getRecommendationSummary(userId);
        summary.put("success", true);
        
        return ResponseEntity.ok(summary);
    }

    @GetMapping("/user/{userId}/type/{type}")
    public ResponseEntity<Map<String, Object>> getRecommendationsByType(
            @PathVariable Long userId,
            @PathVariable String type) {
        
        try {
            UserRecommendation.RecommendationType recommendationType = 
                UserRecommendation.RecommendationType.valueOf(type.toUpperCase());
            
            List<UserRecommendation> recommendations = 
                recommendationService.getRecommendationsByType(userId, recommendationType);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("recommendations", recommendations);
            response.put("type", type);
            
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Invalid recommendation type: " + type);
            return ResponseEntity.badRequest().body(response);
        }
    }

    @GetMapping("/user/{userId}/priority/{priority}")
    public ResponseEntity<Map<String, Object>> getRecommendationsByPriority(
            @PathVariable Long userId,
            @PathVariable String priority) {
        
        try {
            UserRecommendation.PriorityLevel priorityLevel = 
                UserRecommendation.PriorityLevel.valueOf(priority.toUpperCase());
            
            List<UserRecommendation> recommendations = 
                recommendationService.getRecommendationsByPriority(userId, priorityLevel);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("recommendations", recommendations);
            response.put("priority", priority);
            
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Invalid priority level: " + priority);
            return ResponseEntity.badRequest().body(response);
        }
    }

    @GetMapping("/user/{userId}/category/{categoryId}")
    public ResponseEntity<Map<String, Object>> getCategoryRecommendations(
            @PathVariable Long userId,
            @PathVariable Long categoryId) {
        
        List<UserRecommendation> recommendations = 
            recommendationService.getCategoryRecommendations(userId, categoryId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("recommendations", recommendations);
        response.put("categoryId", categoryId);
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/goal/{goalId}")
    public ResponseEntity<Map<String, Object>> getGoalRecommendations(
            @PathVariable Long userId,
            @PathVariable Long goalId) {
        
        List<UserRecommendation> recommendations = 
            recommendationService.getGoalRecommendations(userId, goalId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("recommendations", recommendations);
        response.put("goalId", goalId);
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/unread-count")
    public ResponseEntity<Map<String, Object>> getUnreadCount(@PathVariable Long userId) {
        Long count = recommendationService.getUnreadCount(userId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("unreadCount", count);
        
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createRecommendation(@RequestBody UserRecommendation recommendation) {
        UserRecommendation created = recommendationService.createRecommendation(recommendation);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Recommendation created successfully");
        response.put("recommendation", created);
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/budget-optimization")
    public ResponseEntity<Map<String, Object>> createBudgetOptimizationRecommendation(
            @RequestBody Map<String, Object> request) {
        
        Long userId = Long.valueOf(request.get("userId").toString());
        Long categoryId = Long.valueOf(request.get("categoryId").toString());
        String title = request.get("title").toString();
        String description = request.get("description").toString();
        
        Map<String, Object> response = recommendationService.createBudgetOptimizationRecommendation(
            userId, categoryId, title, description);
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/goal-adjustment")
    public ResponseEntity<Map<String, Object>> createGoalAdjustmentRecommendation(
            @RequestBody Map<String, Object> request) {
        
        Long userId = Long.valueOf(request.get("userId").toString());
        Long goalId = Long.valueOf(request.get("goalId").toString());
        String title = request.get("title").toString();
        String description = request.get("description").toString();
        
        Map<String, Object> response = recommendationService.createGoalAdjustmentRecommendation(
            userId, goalId, title, description);
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/spending-alert")
    public ResponseEntity<Map<String, Object>> createSpendingAlertRecommendation(
            @RequestBody Map<String, Object> request) {
        
        Long userId = Long.valueOf(request.get("userId").toString());
        Long categoryId = Long.valueOf(request.get("categoryId").toString());
        String title = request.get("title").toString();
        String description = request.get("description").toString();
        
        Map<String, Object> response = recommendationService.createSpendingAlertRecommendation(
            userId, categoryId, title, description);
        
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<Map<String, Object>> markAsRead(@PathVariable Long id) {
        Map<String, Object> response = recommendationService.markAsRead(id);
        
        if ((Boolean) response.get("success")) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @PutMapping("/{id}/dismiss")
    public ResponseEntity<Map<String, Object>> dismissRecommendation(@PathVariable Long id) {
        Map<String, Object> response = recommendationService.dismissRecommendation(id);
        
        if ((Boolean) response.get("success")) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @PutMapping("/{id}/action-taken")
    public ResponseEntity<Map<String, Object>> markActionTaken(@PathVariable Long id) {
        Map<String, Object> response = recommendationService.markActionTaken(id);
        
        if ((Boolean) response.get("success")) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteRecommendation(@PathVariable Long id) {
        boolean deleted = recommendationService.deleteRecommendation(id);
        
        Map<String, Object> response = new HashMap<>();
        if (deleted) {
            response.put("success", true);
            response.put("message", "Recommendation deleted successfully");
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "Recommendation not found");
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/cleanup-expired")
    public ResponseEntity<Map<String, Object>> cleanupExpiredRecommendations() {
        recommendationService.cleanupExpiredRecommendations();
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Expired recommendations cleaned up successfully");
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/health")
    @Operation(summary = "Health check", description = "Check if the recommendations service is running")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Insight Service - Recommendations Controller is running!");
    }
}