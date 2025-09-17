package com.example.insightservice.service;

import com.example.insightservice.entity.SpendingAnalytics;
import com.example.insightservice.repository.SpendingAnalyticsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class SpendingAnalyticsService {

    @Autowired
    private SpendingAnalyticsRepository spendingAnalyticsRepository;

    public List<SpendingAnalytics> getUserSpendingAnalytics(Long userId, String period) {
        return spendingAnalyticsRepository.findByUserIdAndAnalysisPeriod(userId, period);
    }

    public List<SpendingAnalytics> getSpendingAnalyticsForDateRange(Long userId, String period, LocalDate startDate, LocalDate endDate) {
        return spendingAnalyticsRepository.findByUserIdAndAnalysisPeriodAndPeriodStartBetween(userId, period, startDate, endDate);
    }

    public List<SpendingAnalytics> getCategorySpendingAnalytics(Long userId, Long categoryId) {
        return spendingAnalyticsRepository.findByUserIdAndCategoryId(userId, categoryId);
    }

    public List<SpendingAnalytics> getRecentAnalytics(Long userId, int months) {
        LocalDate fromDate = LocalDate.now().minusMonths(months);
        return spendingAnalyticsRepository.findRecentAnalyticsForUser(userId, fromDate);
    }

    public List<SpendingAnalytics> getTopSpendingCategories(Long userId, String period) {
        return spendingAnalyticsRepository.findTopSpendingCategoriesForPeriod(userId, period);
    }

    public List<SpendingAnalytics> getIncreasingSpendingTrends(Long userId) {
        return spendingAnalyticsRepository.findIncreasingSpendingTrends(userId);
    }

    public SpendingAnalytics createOrUpdateAnalytics(SpendingAnalytics analytics) {
        // Calculate derived fields
        calculateDerivedFields(analytics);
        return spendingAnalyticsRepository.save(analytics);
    }

    public Map<String, Object> generateSpendingSummary(Long userId, String period) {
        List<SpendingAnalytics> analytics = getUserSpendingAnalytics(userId, period);
        
        Map<String, Object> summary = new HashMap<>();
        
        if (analytics.isEmpty()) {
            summary.put("totalSpending", BigDecimal.ZERO);
            summary.put("categoryCount", 0);
            summary.put("averagePerCategory", BigDecimal.ZERO);
            summary.put("topCategory", null);
            return summary;
        }

        BigDecimal totalSpending = analytics.stream()
                .map(SpendingAnalytics::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        SpendingAnalytics topCategory = analytics.stream()
                .max((a1, a2) -> a1.getTotalAmount().compareTo(a2.getTotalAmount()))
                .orElse(null);

        BigDecimal averagePerCategory = totalSpending.divide(
                BigDecimal.valueOf(analytics.size()), 2, RoundingMode.HALF_UP);

        summary.put("totalSpending", totalSpending);
        summary.put("categoryCount", analytics.size());
        summary.put("averagePerCategory", averagePerCategory);
        summary.put("topCategory", topCategory);
        summary.put("period", period);
        summary.put("analytics", analytics);

        return summary;
    }

    public Map<String, Object> getSpendingTrends(Long userId) {
        List<SpendingAnalytics> increasingTrends = getIncreasingSpendingTrends(userId);
        List<SpendingAnalytics> recentAnalytics = getRecentAnalytics(userId, 6);

        Map<String, Object> trends = new HashMap<>();
        trends.put("increasingTrends", increasingTrends);
        trends.put("recentAnalytics", recentAnalytics);
        trends.put("trendCount", increasingTrends.size());
        
        // Calculate overall trend direction
        if (!recentAnalytics.isEmpty()) {
            long upTrends = recentAnalytics.stream()
                    .filter(a -> "UP".equals(a.getTrendDirection()))
                    .count();
            long totalTrends = recentAnalytics.size();
            
            String overallTrend = upTrends > (totalTrends / 2) ? "INCREASING" : "STABLE_OR_DECREASING";
            trends.put("overallTrend", overallTrend);
        } else {
            trends.put("overallTrend", "NO_DATA");
        }

        return trends;
    }

    private void calculateDerivedFields(SpendingAnalytics analytics) {
        // Calculate average transaction
        if (analytics.getTransactionCount() != null && analytics.getTransactionCount() > 0) {
            BigDecimal average = analytics.getTotalAmount().divide(
                    BigDecimal.valueOf(analytics.getTransactionCount()), 2, RoundingMode.HALF_UP);
            analytics.setAverageTransaction(average);
        }

        // Set default trend direction if not provided
        if (analytics.getTrendDirection() == null) {
            analytics.setTrendDirection("STABLE");
        }

        // Set default trend percentage if not provided
        if (analytics.getTrendPercentage() == null) {
            analytics.setTrendPercentage(BigDecimal.ZERO);
        }
    }

    public boolean deleteAnalytics(Long id) {
        if (spendingAnalyticsRepository.existsById(id)) {
            spendingAnalyticsRepository.deleteById(id);
            return true;
        }
        return false;
    }

    public boolean analyticsExistsForPeriod(Long userId, Long categoryId, String period, LocalDate periodStart) {
        return spendingAnalyticsRepository.existsByUserIdAndCategoryIdAndAnalysisPeriodAndPeriodStart(
                userId, categoryId, period, periodStart);
    }
}