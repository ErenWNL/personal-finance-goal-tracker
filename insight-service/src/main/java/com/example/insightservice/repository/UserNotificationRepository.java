package com.example.insightservice.repository;

import com.example.insightservice.entity.UserNotification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface UserNotificationRepository extends JpaRepository<UserNotification, Long> {

    List<UserNotification> findByUserIdAndIsReadFalse(Long userId);

    List<UserNotification> findByUserIdAndNotificationType(Long userId, UserNotification.NotificationType type);

    List<UserNotification> findByUserIdAndIsUrgentTrue(Long userId);

    @Query("SELECT un FROM UserNotification un WHERE un.userId = :userId ORDER BY un.isUrgent DESC, un.createdAt DESC")
    List<UserNotification> findNotificationsForUserOrderedByPriority(@Param("userId") Long userId);

    @Query("SELECT un FROM UserNotification un WHERE un.userId = :userId AND un.isRead = false ORDER BY un.isUrgent DESC, un.createdAt DESC")
    List<UserNotification> findUnreadNotificationsForUser(@Param("userId") Long userId);

    @Query("SELECT un FROM UserNotification un WHERE un.relatedGoalId = :goalId AND un.userId = :userId")
    List<UserNotification> findNotificationsByGoal(@Param("userId") Long userId, @Param("goalId") Long goalId);

    @Query("SELECT un FROM UserNotification un WHERE un.relatedCategoryId = :categoryId AND un.userId = :userId")
    List<UserNotification> findNotificationsByCategory(@Param("userId") Long userId, @Param("categoryId") Long categoryId);

    @Query("SELECT COUNT(un) FROM UserNotification un WHERE un.userId = :userId AND un.isRead = false")
    Long countUnreadNotifications(@Param("userId") Long userId);

    @Query("SELECT un FROM UserNotification un WHERE un.scheduledFor <= :now AND un.sentAt IS NULL")
    List<UserNotification> findScheduledNotificationsToSend(@Param("now") LocalDateTime now);

    @Query("SELECT un FROM UserNotification un WHERE un.userId = :userId AND un.createdAt >= :fromDate ORDER BY un.createdAt DESC")
    List<UserNotification> findRecentNotifications(@Param("userId") Long userId, @Param("fromDate") LocalDateTime fromDate);
}