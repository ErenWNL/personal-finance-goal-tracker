package com.example.insightservice.service;

import com.example.insightservice.entity.UserRecommendation;
import com.example.insightservice.repository.UserRecommendationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class RecommendationService {

    @Autowired
    private UserRecommendationRepository recommendationRepository;

    public List<UserRecommendation> getActiveRecommendations(Long userId) {
        return recommendationRepository.findActiveRecommendationsForUser(userId, LocalDateTime.now());
    }

    public List<UserRecommendation> getRecommendationsByType(Long userId, UserRecommendation.RecommendationType type) {
        return recommendationRepository.findByUserIdAndRecommendationType(userId, type);
    }

    public List<UserRecommendation> getRecommendationsByPriority(Long userId, UserRecommendation.PriorityLevel priority) {
        return recommendationRepository.findByUserIdAndPriorityLevel(userId, priority);
    }

    public List<UserRecommendation> getCategoryRecommendations(Long userId, Long categoryId) {
        return recommendationRepository.findActiveRecommendationsForCategory(userId, categoryId);
    }

    public List<UserRecommendation> getGoalRecommendations(Long userId, Long goalId) {
        return recommendationRepository.findActiveRecommendationsForGoal(userId, goalId);
    }

    public UserRecommendation createRecommendation(UserRecommendation recommendation) {
        return recommendationRepository.save(recommendation);
    }

    public Map<String, Object> createBudgetOptimizationRecommendation(Long userId, Long categoryId, String title, String description) {
        UserRecommendation recommendation = new UserRecommendation();
        recommendation.setUserId(userId);
        recommendation.setCategoryId(categoryId);
        recommendation.setRecommendationType(UserRecommendation.RecommendationType.BUDGET_OPTIMIZATION);
        recommendation.setTitle(title);
        recommendation.setDescription(description);
        recommendation.setPriorityLevel(UserRecommendation.PriorityLevel.MEDIUM);
        recommendation.setExpiresAt(LocalDateTime.now().plusDays(30)); // Expires in 30 days

        UserRecommendation saved = recommendationRepository.save(recommendation);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Budget optimization recommendation created successfully");
        response.put("recommendation", saved);
        return response;
    }

    public Map<String, Object> createGoalAdjustmentRecommendation(Long userId, Long goalId, String title, String description) {
        UserRecommendation recommendation = new UserRecommendation();
        recommendation.setUserId(userId);
        recommendation.setGoalId(goalId);
        recommendation.setRecommendationType(UserRecommendation.RecommendationType.GOAL_ADJUSTMENT);
        recommendation.setTitle(title);
        recommendation.setDescription(description);
        recommendation.setPriorityLevel(UserRecommendation.PriorityLevel.HIGH);
        recommendation.setExpiresAt(LocalDateTime.now().plusDays(15)); // Expires in 15 days

        UserRecommendation saved = recommendationRepository.save(recommendation);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Goal adjustment recommendation created successfully");
        response.put("recommendation", saved);
        return response;
    }

    public Map<String, Object> createSpendingAlertRecommendation(Long userId, Long categoryId, String title, String description) {
        UserRecommendation recommendation = new UserRecommendation();
        recommendation.setUserId(userId);
        recommendation.setCategoryId(categoryId);
        recommendation.setRecommendationType(UserRecommendation.RecommendationType.SPENDING_ALERT);
        recommendation.setTitle(title);
        recommendation.setDescription(description);
        recommendation.setPriorityLevel(UserRecommendation.PriorityLevel.HIGH);
        recommendation.setExpiresAt(LocalDateTime.now().plusDays(7)); // Expires in 7 days

        UserRecommendation saved = recommendationRepository.save(recommendation);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Spending alert recommendation created successfully");
        response.put("recommendation", saved);
        return response;
    }

    public Map<String, Object> markAsRead(Long recommendationId) {
        Optional<UserRecommendation> optionalRec = recommendationRepository.findById(recommendationId);
        Map<String, Object> response = new HashMap<>();
        
        if (optionalRec.isPresent()) {
            UserRecommendation recommendation = optionalRec.get();
            recommendation.setIsRead(true);
            recommendationRepository.save(recommendation);
            
            response.put("success", true);
            response.put("message", "Recommendation marked as read");
        } else {
            response.put("success", false);
            response.put("message", "Recommendation not found");
        }
        
        return response;
    }

    public Map<String, Object> dismissRecommendation(Long recommendationId) {
        Optional<UserRecommendation> optionalRec = recommendationRepository.findById(recommendationId);
        Map<String, Object> response = new HashMap<>();
        
        if (optionalRec.isPresent()) {
            UserRecommendation recommendation = optionalRec.get();
            recommendation.setIsDismissed(true);
            recommendationRepository.save(recommendation);
            
            response.put("success", true);
            response.put("message", "Recommendation dismissed");
        } else {
            response.put("success", false);
            response.put("message", "Recommendation not found");
        }
        
        return response;
    }

    public Map<String, Object> markActionTaken(Long recommendationId) {
        Optional<UserRecommendation> optionalRec = recommendationRepository.findById(recommendationId);
        Map<String, Object> response = new HashMap<>();
        
        if (optionalRec.isPresent()) {
            UserRecommendation recommendation = optionalRec.get();
            recommendation.setActionTaken(true);
            recommendation.setIsRead(true);
            recommendationRepository.save(recommendation);
            
            response.put("success", true);
            response.put("message", "Recommendation marked as action taken");
        } else {
            response.put("success", false);
            response.put("message", "Recommendation not found");
        }
        
        return response;
    }

    public Long getUnreadCount(Long userId) {
        return recommendationRepository.countUnreadRecommendations(userId);
    }

    public Map<String, Object> getRecommendationSummary(Long userId) {
        List<UserRecommendation> activeRecommendations = getActiveRecommendations(userId);
        Long unreadCount = getUnreadCount(userId);
        
        long highPriorityCount = activeRecommendations.stream()
                .filter(r -> r.getPriorityLevel() == UserRecommendation.PriorityLevel.HIGH || 
                           r.getPriorityLevel() == UserRecommendation.PriorityLevel.CRITICAL)
                .count();
        
        Map<String, Object> summary = new HashMap<>();
        summary.put("totalActive", activeRecommendations.size());
        summary.put("unreadCount", unreadCount);
        summary.put("highPriorityCount", highPriorityCount);
        summary.put("recommendations", activeRecommendations);
        
        return summary;
    }

    public boolean deleteRecommendation(Long recommendationId) {
        if (recommendationRepository.existsById(recommendationId)) {
            recommendationRepository.deleteById(recommendationId);
            return true;
        }
        return false;
    }

    public void cleanupExpiredRecommendations() {
        List<UserRecommendation> expired = recommendationRepository.findExpiredRecommendations(LocalDateTime.now());
        for (UserRecommendation rec : expired) {
            rec.setIsDismissed(true);
            recommendationRepository.save(rec);
        }
    }
}