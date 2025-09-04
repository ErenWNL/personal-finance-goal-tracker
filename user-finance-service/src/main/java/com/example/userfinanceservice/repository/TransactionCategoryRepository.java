package com.example.userfinanceservice.repository;

import com.example.userfinanceservice.entity.TransactionCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TransactionCategoryRepository extends JpaRepository<TransactionCategory, Long> {

    List<TransactionCategory> findByIsDefaultTrue();

    boolean existsByName(String name);
}