package com.example.userfinanceservice.controller;

import com.example.userfinanceservice.dto.request.CategoryRequest;
import com.example.userfinanceservice.dto.request.TransactionRequest;
import com.example.userfinanceservice.dto.response.CategoryResponse;
import com.example.userfinanceservice.dto.response.TransactionResponse;
import com.example.userfinanceservice.service.CategoryService;
import com.example.userfinanceservice.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/finance")
public class FinanceController {

    @Autowired
    private TransactionService transactionService;

    @Autowired
    private CategoryService categoryService;

    // Health Check
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("User Finance Service is running!");
    }

    // Transaction Endpoints
    @PostMapping("/transactions")
    public ResponseEntity<Map<String, Object>> createTransaction(@RequestBody TransactionRequest request) {
        Map<String, Object> response = transactionService.createTransaction(request);
        boolean success = (Boolean) response.get("success");

        if (success) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.badRequest().body(response);
        }
    }

    @GetMapping("/transactions")
    public ResponseEntity<Map<String, Object>> getAllTransactions() {
        Map<String, Object> response = transactionService.getAllTransactions();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/transactions/user/{userId}")
    public ResponseEntity<Map<String, Object>> getTransactionsByUserId(@PathVariable Long userId) {
        Map<String, Object> response = transactionService.getTransactionsByUserId(userId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/transactions/{id}")
    public ResponseEntity<TransactionResponse> getTransactionById(@PathVariable Long id) {
        TransactionResponse transaction = transactionService.getTransactionById(id);
        if (transaction != null) {
            return ResponseEntity.ok(transaction);
        }
        return ResponseEntity.notFound().build();
    }

    @PutMapping("/transactions/{id}")
    public ResponseEntity<Map<String, Object>> updateTransaction(@PathVariable Long id, @RequestBody TransactionRequest request) {
        Map<String, Object> response = transactionService.updateTransaction(id, request);
        boolean success = (Boolean) response.get("success");

        if (success) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.badRequest().body(response);
        }
    }

    @DeleteMapping("/transactions/{id}")
    public ResponseEntity<Map<String, Object>> deleteTransaction(@PathVariable Long id) {
        Map<String, Object> response = transactionService.deleteTransaction(id);
        boolean success = (Boolean) response.get("success");

        if (success) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.badRequest().body(response);
        }
    }

    @GetMapping("/transactions/user/{userId}/summary")
    public ResponseEntity<Map<String, Object>> getUserTransactionSummary(@PathVariable Long userId) {
        Map<String, Object> response = transactionService.getUserTransactionSummary(userId);
        return ResponseEntity.ok(response);
    }

    // Category Endpoints
    @PostMapping("/categories")
    public ResponseEntity<Map<String, Object>> createCategory(@RequestBody CategoryRequest request) {
        Map<String, Object> response = categoryService.createCategory(request);
        boolean success = (Boolean) response.get("success");

        if (success) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.badRequest().body(response);
        }
    }

    @GetMapping("/categories")
    public ResponseEntity<Map<String, Object>> getAllCategories() {
        Map<String, Object> response = categoryService.getAllCategories();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/categories/{id}")
    public ResponseEntity<CategoryResponse> getCategoryById(@PathVariable Long id) {
        CategoryResponse category = categoryService.getCategoryById(id);
        if (category != null) {
            return ResponseEntity.ok(category);
        }
        return ResponseEntity.notFound().build();
    }

    @PutMapping("/categories/{id}")
    public ResponseEntity<Map<String, Object>> updateCategory(@PathVariable Long id, @RequestBody CategoryRequest request) {
        Map<String, Object> response = categoryService.updateCategory(id, request);
        boolean success = (Boolean) response.get("success");

        if (success) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.badRequest().body(response);
        }
    }

    @DeleteMapping("/categories/{id}")
    public ResponseEntity<Map<String, Object>> deleteCategory(@PathVariable Long id) {
        Map<String, Object> response = categoryService.deleteCategory(id);
        boolean success = (Boolean) response.get("success");

        if (success) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.badRequest().body(response);
        }
    }

    @PostMapping("/categories/initialize-defaults")
    public ResponseEntity<Map<String, Object>> initializeDefaultCategories() {
        Map<String, Object> response = categoryService.initializeDefaultCategories();
        return ResponseEntity.ok(response);
    }
}