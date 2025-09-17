package com.example.insightservice.controller;

import com.example.insightservice.client.GoalServiceClient;
import com.example.insightservice.client.UserFinanceServiceClient;
import com.example.insightservice.dto.external.GoalDto;
import com.example.insightservice.dto.external.TransactionDto;
import com.example.insightservice.service.SpendingAnalyticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/integrated")
public class IntegratedInsightController {

    @Autowired
    private UserFinanceServiceClient userFinanceClient;

    @Autowired
    private GoalServiceClient goalServiceClient;

    @Autowired
    private SpendingAnalyticsService analyticsService;

    @GetMapping("/user/{userId}/complete-overview")
    public ResponseEntity<Map<String, Object>> getCompleteUserOverview(@PathVariable Long userId) {
        Map<String, Object> response = new HashMap<>();

        try {
            // Fetch transactions from User Finance Service
            List<TransactionDto> transactions = userFinanceClient.getUserTransactions(userId);

            // Fetch goals from Goal Service
            List<GoalDto> goals = goalServiceClient.getUserGoals(userId);

            // Fetch transaction summary
            Map<String, Object> transactionSummary = userFinanceClient.getUserTransactionSummary(userId);

            // Fetch analytics
            Map<String, Object> analyticsSummary = analyticsService.generateSpendingSummary(userId, "MONTHLY");

            // Calculate combined insights
            Map<String, Object> insights = generateCombinedInsights(transactions, goals);

            response.put("success", true);
            response.put("userId", userId);
            response.put("transactions", transactions);
            response.put("goals", goals);
            response.put("transactionSummary", transactionSummary);
            response.put("analyticsSummary", analyticsSummary);
            response.put("combinedInsights", insights);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error fetching complete overview");
            response.put("error", e.getMessage());
        }

        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/goal-progress-analysis")
    public ResponseEntity<Map<String, Object>> getGoalProgressAnalysis(@PathVariable Long userId) {
        Map<String, Object> response = new HashMap<>();

        try {
            // Fetch goals
            List<GoalDto> goals = goalServiceClient.getUserGoals(userId);

            // Fetch transactions
            List<TransactionDto> transactions = userFinanceClient.getUserTransactions(userId);

            // Calculate goal-related insights
            Map<String, Object> goalAnalysis = analyzeGoalProgress(goals, transactions);

            response.put("success", true);
            response.put("userId", userId);
            response.put("goalAnalysis", goalAnalysis);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error analyzing goal progress");
            response.put("error", e.getMessage());
        }

        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/spending-vs-goals")
    public ResponseEntity<Map<String, Object>> getSpendingVsGoals(@PathVariable Long userId) {
        Map<String, Object> response = new HashMap<>();

        try {
            // Fetch transactions
            List<TransactionDto> transactions = userFinanceClient.getUserTransactions(userId);

            // Fetch goals
            List<GoalDto> goals = goalServiceClient.getUserGoals(userId);

            // Fetch categories
            List<Map<String, Object>> categories = userFinanceClient.getAllCategories();

            // Calculate spending vs goals analysis
            Map<String, Object> analysis = analyzeSpendingVsGoals(transactions, goals, categories);

            response.put("success", true);
            response.put("userId", userId);
            response.put("spendingVsGoalsAnalysis", analysis);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error analyzing spending vs goals");
            response.put("error", e.getMessage());
        }

        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/recommendations")
    public ResponseEntity<Map<String, Object>> getPersonalizedRecommendations(@PathVariable Long userId) {
        Map<String, Object> response = new HashMap<>();

        try {
            // Fetch all user data
            List<TransactionDto> transactions = userFinanceClient.getUserTransactions(userId);
            List<GoalDto> goals = goalServiceClient.getUserGoals(userId);
            Map<String, Object> transactionSummary = userFinanceClient.getUserTransactionSummary(userId);

            // Generate personalized recommendations
            List<Map<String, Object>> recommendations = generatePersonalizedRecommendations(
                transactions, goals, transactionSummary);

            response.put("success", true);
            response.put("userId", userId);
            response.put("recommendations", recommendations);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error generating recommendations");
            response.put("error", e.getMessage());
        }

        return ResponseEntity.ok(response);
    }

    private Map<String, Object> generateCombinedInsights(List<TransactionDto> transactions, List<GoalDto> goals) {
        Map<String, Object> insights = new HashMap<>();

        // Calculate total transactions
        BigDecimal totalSpent = transactions.stream()
            .filter(t -> "EXPENSE".equals(t.getType()))
            .map(TransactionDto::getAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal totalIncome = transactions.stream()
            .filter(t -> "INCOME".equals(t.getType()))
            .map(TransactionDto::getAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        // Calculate total goal targets
        BigDecimal totalGoalTargets = goals.stream()
            .map(GoalDto::getTargetAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal totalGoalProgress = goals.stream()
            .map(GoalDto::getCurrentAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        insights.put("totalSpent", totalSpent);
        insights.put("totalIncome", totalIncome);
        insights.put("netSavings", totalIncome.subtract(totalSpent));
        insights.put("totalGoalTargets", totalGoalTargets);
        insights.put("totalGoalProgress", totalGoalProgress);
        insights.put("overallGoalProgress",
            totalGoalTargets.compareTo(BigDecimal.ZERO) > 0 ?
                totalGoalProgress.divide(totalGoalTargets, 4, BigDecimal.ROUND_HALF_UP).multiply(BigDecimal.valueOf(100)) :
                BigDecimal.ZERO);

        return insights;
    }

    private Map<String, Object> analyzeGoalProgress(List<GoalDto> goals, List<TransactionDto> transactions) {
        Map<String, Object> analysis = new HashMap<>();

        // Count goals by status
        Map<String, Long> goalsByStatus = goals.stream()
            .collect(java.util.stream.Collectors.groupingBy(
                GoalDto::getStatus,
                java.util.stream.Collectors.counting()
            ));

        // Find goal-related transactions
        List<TransactionDto> goalTransactions = transactions.stream()
            .filter(t -> t.getGoalId() != null)
            .toList();

        analysis.put("totalGoals", goals.size());
        analysis.put("goalsByStatus", goalsByStatus);
        analysis.put("goalRelatedTransactions", goalTransactions.size());
        analysis.put("goals", goals);

        return analysis;
    }

    private Map<String, Object> analyzeSpendingVsGoals(List<TransactionDto> transactions,
                                                       List<GoalDto> goals,
                                                       List<Map<String, Object>> categories) {
        Map<String, Object> analysis = new HashMap<>();

        // Group expenses by category
        Map<Long, BigDecimal> spendingByCategory = transactions.stream()
            .filter(t -> "EXPENSE".equals(t.getType()) && t.getCategoryId() != null)
            .collect(java.util.stream.Collectors.groupingBy(
                TransactionDto::getCategoryId,
                java.util.stream.Collectors.reducing(
                    BigDecimal.ZERO,
                    TransactionDto::getAmount,
                    BigDecimal::add
                )
            ));

        // Group goals by category
        Map<Long, List<GoalDto>> goalsByCategory = goals.stream()
            .filter(g -> g.getCategoryId() != null)
            .collect(java.util.stream.Collectors.groupingBy(GoalDto::getCategoryId));

        analysis.put("spendingByCategory", spendingByCategory);
        analysis.put("goalsByCategory", goalsByCategory);
        analysis.put("categories", categories);

        return analysis;
    }

    private List<Map<String, Object>> generatePersonalizedRecommendations(List<TransactionDto> transactions,
                                                                         List<GoalDto> goals,
                                                                         Map<String, Object> transactionSummary) {
        List<Map<String, Object>> recommendations = new java.util.ArrayList<>();

        // Recommendation 1: High spending categories
        Map<Long, BigDecimal> spendingByCategory = transactions.stream()
            .filter(t -> "EXPENSE".equals(t.getType()) && t.getCategoryId() != null)
            .collect(java.util.stream.Collectors.groupingBy(
                TransactionDto::getCategoryId,
                java.util.stream.Collectors.reducing(
                    BigDecimal.ZERO,
                    TransactionDto::getAmount,
                    BigDecimal::add
                )
            ));

        if (!spendingByCategory.isEmpty()) {
            Long highestSpendingCategory = spendingByCategory.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(null);

            if (highestSpendingCategory != null) {
                Map<String, Object> recommendation = new HashMap<>();
                recommendation.put("type", "BUDGET_ALERT");
                recommendation.put("title", "Review High Spending Category");
                recommendation.put("description", "Category " + highestSpendingCategory + " has the highest spending. Consider setting a budget limit.");
                recommendation.put("categoryId", highestSpendingCategory);
                recommendation.put("priority", "HIGH");
                recommendations.add(recommendation);
            }
        }

        // Recommendation 2: Goal progress
        long activeGoals = goals.stream()
            .filter(g -> "ACTIVE".equals(g.getStatus()))
            .count();

        if (activeGoals == 0) {
            Map<String, Object> recommendation = new HashMap<>();
            recommendation.put("type", "GOAL_SUGGESTION");
            recommendation.put("title", "Set Financial Goals");
            recommendation.put("description", "Setting financial goals can help you save more effectively. Consider creating your first goal.");
            recommendation.put("priority", "MEDIUM");
            recommendations.add(recommendation);
        }

        // Recommendation 3: Savings potential
        BigDecimal totalIncome = transactions.stream()
            .filter(t -> "INCOME".equals(t.getType()))
            .map(TransactionDto::getAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal totalExpenses = transactions.stream()
            .filter(t -> "EXPENSE".equals(t.getType()))
            .map(TransactionDto::getAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        if (totalIncome.compareTo(BigDecimal.ZERO) > 0 && totalExpenses.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal savingsRate = totalIncome.subtract(totalExpenses).divide(totalIncome, 4, BigDecimal.ROUND_HALF_UP);

            if (savingsRate.compareTo(BigDecimal.valueOf(0.2)) < 0) {
                Map<String, Object> recommendation = new HashMap<>();
                recommendation.put("type", "SAVINGS_IMPROVEMENT");
                recommendation.put("title", "Increase Savings Rate");
                recommendation.put("description", "Your current savings rate is " + savingsRate.multiply(BigDecimal.valueOf(100)).intValue() + "%. Consider aiming for 20% or higher.");
                recommendation.put("currentSavingsRate", savingsRate.multiply(BigDecimal.valueOf(100)));
                recommendation.put("priority", "HIGH");
                recommendations.add(recommendation);
            }
        }

        return recommendations;
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Integrated Insight Controller is running!");
    }
}