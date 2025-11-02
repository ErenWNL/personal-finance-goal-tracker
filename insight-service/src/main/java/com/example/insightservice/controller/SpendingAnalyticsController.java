package com.example.insightservice.controller;

import com.example.insightservice.entity.SpendingAnalytics;
import com.example.insightservice.service.SpendingAnalyticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/analytics")
@Tag(name = "Analytics", description = "Spending analytics and insights endpoints")
public class SpendingAnalyticsController {

    @Autowired
    private SpendingAnalyticsService analyticsService;

    @GetMapping("/user/{userId}")
    @Operation(summary = "Get spending analytics", description = "Get spending analytics for a user by period (DAILY, WEEKLY, MONTHLY, YEARLY)")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Analytics retrieved successfully"),
            @ApiResponse(responseCode = "404", description = "User not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public ResponseEntity<Map<String, Object>> getUserSpendingAnalytics(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "MONTHLY") String period) {
        
        List<SpendingAnalytics> analytics = analyticsService.getUserSpendingAnalytics(userId, period);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("analytics", analytics);
        response.put("count", analytics.size());
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/summary")
    public ResponseEntity<Map<String, Object>> getSpendingSummary(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "MONTHLY") String period) {
        
        Map<String, Object> summary = analyticsService.generateSpendingSummary(userId, period);
        summary.put("success", true);
        
        return ResponseEntity.ok(summary);
    }

    @GetMapping("/user/{userId}/trends")
    public ResponseEntity<Map<String, Object>> getSpendingTrends(@PathVariable Long userId) {
        Map<String, Object> trends = analyticsService.getSpendingTrends(userId);
        trends.put("success", true);
        
        return ResponseEntity.ok(trends);
    }

    @GetMapping("/user/{userId}/category/{categoryId}")
    public ResponseEntity<Map<String, Object>> getCategoryAnalytics(
            @PathVariable Long userId,
            @PathVariable Long categoryId) {
        
        List<SpendingAnalytics> analytics = analyticsService.getCategorySpendingAnalytics(userId, categoryId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("analytics", analytics);
        response.put("categoryId", categoryId);
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/top-categories")
    public ResponseEntity<Map<String, Object>> getTopSpendingCategories(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "MONTHLY") String period) {
        
        List<SpendingAnalytics> topCategories = analyticsService.getTopSpendingCategories(userId, period);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("topCategories", topCategories);
        response.put("period", period);
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/recent")
    public ResponseEntity<Map<String, Object>> getRecentAnalytics(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "6") int months) {
        
        List<SpendingAnalytics> recentAnalytics = analyticsService.getRecentAnalytics(userId, months);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("analytics", recentAnalytics);
        response.put("monthsBack", months);
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/increasing-trends")
    public ResponseEntity<Map<String, Object>> getIncreasingTrends(@PathVariable Long userId) {
        List<SpendingAnalytics> trends = analyticsService.getIncreasingSpendingTrends(userId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("increasingTrends", trends);
        response.put("count", trends.size());
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/date-range")
    public ResponseEntity<Map<String, Object>> getAnalyticsForDateRange(
            @PathVariable Long userId,
            @RequestParam String period,
            @RequestParam String startDate,
            @RequestParam String endDate) {
        
        LocalDate start = LocalDate.parse(startDate);
        LocalDate end = LocalDate.parse(endDate);
        
        List<SpendingAnalytics> analytics = analyticsService.getSpendingAnalyticsForDateRange(userId, period, start, end);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("analytics", analytics);
        response.put("dateRange", Map.of("start", startDate, "end", endDate));
        
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createAnalytics(@RequestBody SpendingAnalytics analytics) {
        SpendingAnalytics created = analyticsService.createOrUpdateAnalytics(analytics);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Analytics created successfully");
        response.put("analytics", created);
        
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateAnalytics(
            @PathVariable Long id,
            @RequestBody SpendingAnalytics analytics) {
        
        analytics.setId(id);
        SpendingAnalytics updated = analyticsService.createOrUpdateAnalytics(analytics);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Analytics updated successfully");
        response.put("analytics", updated);
        
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteAnalytics(@PathVariable Long id) {
        boolean deleted = analyticsService.deleteAnalytics(id);
        
        Map<String, Object> response = new HashMap<>();
        if (deleted) {
            response.put("success", true);
            response.put("message", "Analytics deleted successfully");
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "Analytics not found");
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/health")
    @Operation(summary = "Health check", description = "Check if the analytics service is running")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Insight Service - Analytics Controller is running!");
    }
}