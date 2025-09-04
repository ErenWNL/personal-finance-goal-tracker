package com.example.userfinanceservice.repository;

import com.example.userfinanceservice.entity.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {

    List<Transaction> findByUserId(Long userId);

    List<Transaction> findByUserIdOrderByTransactionDateDesc(Long userId);

    List<Transaction> findByUserIdAndTransactionDateBetween(Long userId, LocalDate startDate, LocalDate endDate);

    List<Transaction> findByUserIdAndTransactionType(Long userId, String transactionType);

    @Query("SELECT SUM(t.amount) FROM Transaction t WHERE t.userId = :userId AND t.transactionType = :type")
    BigDecimal getTotalAmountByUserIdAndType(Long userId, String type);

    @Query("SELECT SUM(t.amount) FROM Transaction t WHERE t.userId = :userId AND t.transactionType = :type AND t.transactionDate BETWEEN :startDate AND :endDate")
    BigDecimal getTotalAmountByUserIdAndTypeAndDateRange(Long userId, String type, LocalDate startDate, LocalDate endDate);
}