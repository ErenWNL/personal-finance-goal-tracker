package com.example.insightservice.repository;

import com.example.insightservice.entity.UserRecommendation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface UserRecommendationRepository extends JpaRepository<UserRecommendation, Long> {

    List<UserRecommendation> findByUserIdAndIsReadFalseAndIsDismissedFalse(Long userId);

    List<UserRecommendation> findByUserIdAndRecommendationType(Long userId, UserRecommendation.RecommendationType type);

    List<UserRecommendation> findByUserIdAndPriorityLevel(Long userId, UserRecommendation.PriorityLevel priority);

    @Query("SELECT ur FROM UserRecommendation ur WHERE ur.userId = :userId AND ur.isRead = false AND ur.isDismissed = false AND (ur.expiresAt IS NULL OR ur.expiresAt > :now) ORDER BY ur.priorityLevel DESC, ur.createdAt DESC")
    List<UserRecommendation> findActiveRecommendationsForUser(@Param("userId") Long userId, @Param("now") LocalDateTime now);

    @Query("SELECT ur FROM UserRecommendation ur WHERE ur.userId = :userId AND ur.categoryId = :categoryId AND ur.isRead = false AND ur.isDismissed = false")
    List<UserRecommendation> findActiveRecommendationsForCategory(@Param("userId") Long userId, @Param("categoryId") Long categoryId);

    @Query("SELECT ur FROM UserRecommendation ur WHERE ur.userId = :userId AND ur.goalId = :goalId AND ur.isRead = false AND ur.isDismissed = false")
    List<UserRecommendation> findActiveRecommendationsForGoal(@Param("userId") Long userId, @Param("goalId") Long goalId);

    @Query("SELECT COUNT(ur) FROM UserRecommendation ur WHERE ur.userId = :userId AND ur.isRead = false AND ur.isDismissed = false")
    Long countUnreadRecommendations(@Param("userId") Long userId);

    @Query("SELECT ur FROM UserRecommendation ur WHERE ur.expiresAt <= :now AND ur.isDismissed = false")
    List<UserRecommendation> findExpiredRecommendations(@Param("now") LocalDateTime now);
}