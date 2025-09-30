package com.example.insightservice.repository;

import com.example.insightservice.entity.SpendingAnalytics;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface SpendingAnalyticsRepository extends JpaRepository<SpendingAnalytics, Long> {

    List<SpendingAnalytics> findByUserIdAndAnalysisPeriod(Long userId, String analysisPeriod);

    List<SpendingAnalytics> findByUserIdAndCategoryId(Long userId, Long categoryId);

    @Query("SELECT sa FROM SpendingAnalytics sa WHERE sa.userId = :userId AND sa.analysisMonth >= :fromDate ORDER BY sa.analysisMonth DESC")
    List<SpendingAnalytics> findRecentAnalyticsForUser(@Param("userId") Long userId, @Param("fromDate") LocalDate fromDate);

    @Query("SELECT sa FROM SpendingAnalytics sa WHERE sa.userId = :userId AND sa.analysisPeriod = :period ORDER BY sa.totalAmount DESC")
    List<SpendingAnalytics> findTopSpendingCategoriesForPeriod(@Param("userId") Long userId, @Param("period") String period);

    @Query("SELECT sa FROM SpendingAnalytics sa WHERE sa.userId = :userId AND sa.trendDirection = 'UP' ORDER BY sa.trendPercentage DESC")
    List<SpendingAnalytics> findIncreasingSpendingTrends(@Param("userId") Long userId);

    boolean existsByUserIdAndCategoryIdAndAnalysisPeriodAndAnalysisMonth(
            Long userId, Long categoryId, String analysisPeriod, LocalDate analysisMonth);
}