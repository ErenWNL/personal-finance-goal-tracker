package com.example.goalservice.repository;

import com.example.goalservice.entity.Goal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GoalRepository extends JpaRepository<Goal, Long> {

    @Query(value = "SELECT * FROM goals WHERE user_id = 1", nativeQuery = true)
    List<Goal> findTestUser1Goals();

    @Query(value = "SELECT * FROM goals WHERE user_id = :userId", nativeQuery = true)
    List<Goal> findByUserId(@Param("userId") Long userId);

    @Query(value = "SELECT * FROM goals WHERE user_id = :userId ORDER BY created_at DESC", nativeQuery = true)
    List<Goal> findByUserIdOrderByCreatedAtDesc(@Param("userId") Long userId);
}