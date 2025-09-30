package com.example.userfinanceservice.repository;

import com.example.userfinanceservice.entity.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {

    @Query(value = "SELECT * FROM transactions WHERE user_id = :userId", nativeQuery = true)
    List<Transaction> findByUserId(@Param("userId") Long userId);

    @Query(value = "SELECT * FROM transactions WHERE user_id = :userId ORDER BY transaction_date DESC", nativeQuery = true)
    List<Transaction> findByUserIdOrderByTransactionDateDesc(@Param("userId") Long userId);

    @Query("SELECT t FROM Transaction t WHERE t.userId = :userId AND t.transactionDate BETWEEN :startDate AND :endDate")
    List<Transaction> findByUserIdAndTransactionDateBetween(@Param("userId") Long userId, @Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);

    @Query("SELECT t FROM Transaction t WHERE t.userId = :userId AND t.transactionType = :transactionType")
    List<Transaction> findByUserIdAndTransactionType(@Param("userId") Long userId, @Param("transactionType") Transaction.TransactionType transactionType);

    @Query("SELECT SUM(t.amount) FROM Transaction t WHERE t.userId = :userId AND t.transactionType = :type")
    BigDecimal getTotalAmountByUserIdAndType(@Param("userId") Long userId, @Param("type") Transaction.TransactionType type);

    @Query("SELECT SUM(t.amount) FROM Transaction t WHERE t.userId = :userId AND t.transactionType = :type AND t.transactionDate BETWEEN :startDate AND :endDate")
    BigDecimal getTotalAmountByUserIdAndTypeAndDateRange(@Param("userId") Long userId, @Param("type") Transaction.TransactionType type, @Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
}