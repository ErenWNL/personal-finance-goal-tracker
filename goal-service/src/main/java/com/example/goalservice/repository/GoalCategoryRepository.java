package com.example.goalservice.repository;

import com.example.goalservice.entity.GoalCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface GoalCategoryRepository extends JpaRepository<GoalCategory, Long> {
    boolean existsByName(String name);
}