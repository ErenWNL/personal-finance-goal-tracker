package com.example.insightservice.controller;

import com.example.insightservice.entity.UserNotification;
import com.example.insightservice.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/notifications")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> getUserNotifications(@PathVariable Long userId) {
        List<UserNotification> notifications = notificationService.getUserNotifications(userId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("notifications", notifications);
        response.put("count", notifications.size());
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/unread")
    public ResponseEntity<Map<String, Object>> getUnreadNotifications(@PathVariable Long userId) {
        List<UserNotification> notifications = notificationService.getUnreadNotifications(userId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("notifications", notifications);
        response.put("count", notifications.size());
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/urgent")
    public ResponseEntity<Map<String, Object>> getUrgentNotifications(@PathVariable Long userId) {
        List<UserNotification> notifications = notificationService.getUrgentNotifications(userId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("urgentNotifications", notifications);
        response.put("count", notifications.size());
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/summary")
    public ResponseEntity<Map<String, Object>> getNotificationSummary(@PathVariable Long userId) {
        Map<String, Object> summary = notificationService.getNotificationSummary(userId);
        summary.put("success", true);
        
        return ResponseEntity.ok(summary);
    }

    @GetMapping("/user/{userId}/type/{type}")
    public ResponseEntity<Map<String, Object>> getNotificationsByType(
            @PathVariable Long userId,
            @PathVariable String type) {
        
        try {
            UserNotification.NotificationType notificationType = 
                UserNotification.NotificationType.valueOf(type.toUpperCase());
            
            List<UserNotification> notifications = 
                notificationService.getNotificationsByType(userId, notificationType);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("notifications", notifications);
            response.put("type", type);
            
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Invalid notification type: " + type);
            return ResponseEntity.badRequest().body(response);
        }
    }

    @GetMapping("/user/{userId}/goal/{goalId}")
    public ResponseEntity<Map<String, Object>> getGoalNotifications(
            @PathVariable Long userId,
            @PathVariable Long goalId) {
        
        List<UserNotification> notifications = 
            notificationService.getGoalNotifications(userId, goalId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("notifications", notifications);
        response.put("goalId", goalId);
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/category/{categoryId}")
    public ResponseEntity<Map<String, Object>> getCategoryNotifications(
            @PathVariable Long userId,
            @PathVariable Long categoryId) {
        
        List<UserNotification> notifications = 
            notificationService.getCategoryNotifications(userId, categoryId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("notifications", notifications);
        response.put("categoryId", categoryId);
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/recent")
    public ResponseEntity<Map<String, Object>> getRecentNotifications(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "7") int days) {
        
        List<UserNotification> notifications = notificationService.getRecentNotifications(userId, days);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("notifications", notifications);
        response.put("daysBack", days);
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/unread-count")
    public ResponseEntity<Map<String, Object>> getUnreadCount(@PathVariable Long userId) {
        Long count = notificationService.getUnreadCount(userId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("unreadCount", count);
        
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createNotification(@RequestBody UserNotification notification) {
        UserNotification created = notificationService.createNotification(notification);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Notification created successfully");
        response.put("notification", created);
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/goal-deadline")
    public ResponseEntity<Map<String, Object>> createGoalDeadlineNotification(
            @RequestBody Map<String, Object> request) {
        
        Long userId = Long.valueOf(request.get("userId").toString());
        Long goalId = Long.valueOf(request.get("goalId").toString());
        String title = request.get("title").toString();
        String message = request.get("message").toString();
        
        Map<String, Object> response = notificationService.createGoalDeadlineNotification(
            userId, goalId, title, message);
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/budget-exceeded")
    public ResponseEntity<Map<String, Object>> createBudgetExceededNotification(
            @RequestBody Map<String, Object> request) {
        
        Long userId = Long.valueOf(request.get("userId").toString());
        Long categoryId = Long.valueOf(request.get("categoryId").toString());
        String title = request.get("title").toString();
        String message = request.get("message").toString();
        
        Map<String, Object> response = notificationService.createBudgetExceededNotification(
            userId, categoryId, title, message);
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/spending-alert")
    public ResponseEntity<Map<String, Object>> createSpendingAlertNotification(
            @RequestBody Map<String, Object> request) {
        
        Long userId = Long.valueOf(request.get("userId").toString());
        Long categoryId = Long.valueOf(request.get("categoryId").toString());
        String title = request.get("title").toString();
        String message = request.get("message").toString();
        
        Map<String, Object> response = notificationService.createSpendingAlertNotification(
            userId, categoryId, title, message);
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/goal-milestone")
    public ResponseEntity<Map<String, Object>> createGoalMilestoneNotification(
            @RequestBody Map<String, Object> request) {
        
        Long userId = Long.valueOf(request.get("userId").toString());
        Long goalId = Long.valueOf(request.get("goalId").toString());
        String title = request.get("title").toString();
        String message = request.get("message").toString();
        
        Map<String, Object> response = notificationService.createGoalMilestoneNotification(
            userId, goalId, title, message);
        
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<Map<String, Object>> markAsRead(@PathVariable Long id) {
        Map<String, Object> response = notificationService.markAsRead(id);
        
        if ((Boolean) response.get("success")) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @PutMapping("/user/{userId}/read-all")
    public ResponseEntity<Map<String, Object>> markAllAsRead(@PathVariable Long userId) {
        Map<String, Object> response = notificationService.markAllAsRead(userId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteNotification(@PathVariable Long id) {
        boolean deleted = notificationService.deleteNotification(id);
        
        Map<String, Object> response = new HashMap<>();
        if (deleted) {
            response.put("success", true);
            response.put("message", "Notification deleted successfully");
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "Notification not found");
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/scheduled-to-send")
    public ResponseEntity<Map<String, Object>> getScheduledNotificationsToSend() {
        List<UserNotification> notifications = notificationService.getScheduledNotificationsToSend();
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("notifications", notifications);
        response.put("count", notifications.size());
        
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}/mark-sent")
    public ResponseEntity<Map<String, Object>> markAsSent(@PathVariable Long id) {
        notificationService.markAsSent(id);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Notification marked as sent");
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Insight Service - Notifications Controller is running!");
    }
}