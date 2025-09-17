package com.example.insightservice.service;

import com.example.insightservice.entity.UserNotification;
import com.example.insightservice.repository.UserNotificationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class NotificationService {

    @Autowired
    private UserNotificationRepository notificationRepository;

    public List<UserNotification> getUserNotifications(Long userId) {
        return notificationRepository.findNotificationsForUserOrderedByPriority(userId);
    }

    public List<UserNotification> getUnreadNotifications(Long userId) {
        return notificationRepository.findUnreadNotificationsForUser(userId);
    }

    public List<UserNotification> getUrgentNotifications(Long userId) {
        return notificationRepository.findByUserIdAndIsUrgentTrue(userId);
    }

    public List<UserNotification> getNotificationsByType(Long userId, UserNotification.NotificationType type) {
        return notificationRepository.findByUserIdAndNotificationType(userId, type);
    }

    public List<UserNotification> getGoalNotifications(Long userId, Long goalId) {
        return notificationRepository.findNotificationsByGoal(userId, goalId);
    }

    public List<UserNotification> getCategoryNotifications(Long userId, Long categoryId) {
        return notificationRepository.findNotificationsByCategory(userId, categoryId);
    }

    public List<UserNotification> getRecentNotifications(Long userId, int days) {
        LocalDateTime fromDate = LocalDateTime.now().minusDays(days);
        return notificationRepository.findRecentNotifications(userId, fromDate);
    }

    public UserNotification createNotification(UserNotification notification) {
        if (notification.getScheduledFor() == null) {
            notification.setScheduledFor(LocalDateTime.now());
        }
        return notificationRepository.save(notification);
    }

    public Map<String, Object> createGoalDeadlineNotification(Long userId, Long goalId, String title, String message) {
        UserNotification notification = new UserNotification();
        notification.setUserId(userId);
        notification.setRelatedGoalId(goalId);
        notification.setNotificationType(UserNotification.NotificationType.GOAL_DEADLINE);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setIsUrgent(true);
        notification.setScheduledFor(LocalDateTime.now());

        UserNotification saved = notificationRepository.save(notification);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Goal deadline notification created successfully");
        response.put("notification", saved);
        return response;
    }

    public Map<String, Object> createBudgetExceededNotification(Long userId, Long categoryId, String title, String message) {
        UserNotification notification = new UserNotification();
        notification.setUserId(userId);
        notification.setRelatedCategoryId(categoryId);
        notification.setNotificationType(UserNotification.NotificationType.BUDGET_EXCEEDED);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setIsUrgent(true);
        notification.setScheduledFor(LocalDateTime.now());

        UserNotification saved = notificationRepository.save(notification);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Budget exceeded notification created successfully");
        response.put("notification", saved);
        return response;
    }

    public Map<String, Object> createSpendingAlertNotification(Long userId, Long categoryId, String title, String message) {
        UserNotification notification = new UserNotification();
        notification.setUserId(userId);
        notification.setRelatedCategoryId(categoryId);
        notification.setNotificationType(UserNotification.NotificationType.SPENDING_ALERT);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setIsUrgent(false);
        notification.setScheduledFor(LocalDateTime.now());

        UserNotification saved = notificationRepository.save(notification);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Spending alert notification created successfully");
        response.put("notification", saved);
        return response;
    }

    public Map<String, Object> createGoalMilestoneNotification(Long userId, Long goalId, String title, String message) {
        UserNotification notification = new UserNotification();
        notification.setUserId(userId);
        notification.setRelatedGoalId(goalId);
        notification.setNotificationType(UserNotification.NotificationType.GOAL_MILESTONE);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setIsUrgent(false);
        notification.setScheduledFor(LocalDateTime.now());

        UserNotification saved = notificationRepository.save(notification);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Goal milestone notification created successfully");
        response.put("notification", saved);
        return response;
    }

    public Map<String, Object> markAsRead(Long notificationId) {
        Optional<UserNotification> optionalNotification = notificationRepository.findById(notificationId);
        Map<String, Object> response = new HashMap<>();
        
        if (optionalNotification.isPresent()) {
            UserNotification notification = optionalNotification.get();
            notification.setIsRead(true);
            notificationRepository.save(notification);
            
            response.put("success", true);
            response.put("message", "Notification marked as read");
        } else {
            response.put("success", false);
            response.put("message", "Notification not found");
        }
        
        return response;
    }

    public Map<String, Object> markAllAsRead(Long userId) {
        List<UserNotification> unreadNotifications = getUnreadNotifications(userId);
        
        for (UserNotification notification : unreadNotifications) {
            notification.setIsRead(true);
            notificationRepository.save(notification);
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "All notifications marked as read");
        response.put("markedCount", unreadNotifications.size());
        return response;
    }

    public Long getUnreadCount(Long userId) {
        return notificationRepository.countUnreadNotifications(userId);
    }

    public Map<String, Object> getNotificationSummary(Long userId) {
        List<UserNotification> allNotifications = getUserNotifications(userId);
        List<UserNotification> unreadNotifications = getUnreadNotifications(userId);
        List<UserNotification> urgentNotifications = getUrgentNotifications(userId);
        Long unreadCount = getUnreadCount(userId);
        
        Map<String, Object> summary = new HashMap<>();
        summary.put("totalNotifications", allNotifications.size());
        summary.put("unreadCount", unreadCount);
        summary.put("urgentCount", urgentNotifications.size());
        summary.put("recentNotifications", getRecentNotifications(userId, 7));
        summary.put("unreadNotifications", unreadNotifications);
        
        return summary;
    }

    public boolean deleteNotification(Long notificationId) {
        if (notificationRepository.existsById(notificationId)) {
            notificationRepository.deleteById(notificationId);
            return true;
        }
        return false;
    }

    public List<UserNotification> getScheduledNotificationsToSend() {
        return notificationRepository.findScheduledNotificationsToSend(LocalDateTime.now());
    }

    public void markAsSent(Long notificationId) {
        Optional<UserNotification> optionalNotification = notificationRepository.findById(notificationId);
        if (optionalNotification.isPresent()) {
            UserNotification notification = optionalNotification.get();
            notification.setSentAt(LocalDateTime.now());
            notificationRepository.save(notification);
        }
    }
}