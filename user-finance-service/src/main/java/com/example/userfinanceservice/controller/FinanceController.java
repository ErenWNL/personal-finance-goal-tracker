package com.example.userfinanceservice.controller;

import com.example.userfinanceservice.dto.request.CategoryRequest;
import com.example.userfinanceservice.dto.request.TransactionRequest;
import com.example.userfinanceservice.dto.response.CategoryResponse;
import com.example.userfinanceservice.dto.response.TransactionResponse;
import com.example.userfinanceservice.service.CategoryService;
import com.example.userfinanceservice.service.TransactionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/finance")
@Tag(name = "Finance", description = "Transaction and category management endpoints")
public class FinanceController {

    @Autowired
    private TransactionService transactionService;

    @Autowired
    private CategoryService categoryService;

    // Health Check
    @GetMapping("/health")
    @Operation(summary = "Health check", description = "Check if the finance service is running")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("User Finance Service is running!");
    }

    // Transaction Endpoints
    @PostMapping("/transactions")
    @Operation(summary = "Create transaction", description = "Create a new income or expense transaction")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Transaction created successfully"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
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
    @Operation(summary = "Get all transactions", description = "Retrieve all transactions from the system")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Transactions retrieved successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public ResponseEntity<Map<String, Object>> getAllTransactions() {
        Map<String, Object> response = transactionService.getAllTransactions();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/transactions/user/{userId}")
    @Operation(summary = "Get user transactions", description = "Retrieve all transactions for a specific user")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User transactions retrieved successfully"),
            @ApiResponse(responseCode = "404", description = "User not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public ResponseEntity<Map<String, Object>> getTransactionsByUserId(@PathVariable Long userId) {
        Map<String, Object> response = transactionService.getTransactionsByUserId(userId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/transactions/{id}")
    @Operation(summary = "Get transaction by ID", description = "Retrieve a specific transaction by ID")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Transaction found"),
            @ApiResponse(responseCode = "404", description = "Transaction not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public ResponseEntity<TransactionResponse> getTransactionById(@PathVariable Long id) {
        TransactionResponse transaction = transactionService.getTransactionById(id);
        if (transaction != null) {
            return ResponseEntity.ok(transaction);
        }
        return ResponseEntity.notFound().build();
    }

    @PutMapping("/transactions/{id}")
    @Operation(summary = "Update transaction", description = "Update an existing transaction")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Transaction updated successfully"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "Transaction not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
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
    @Operation(summary = "Delete transaction", description = "Delete a transaction by ID")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Transaction deleted successfully"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "Transaction not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
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
    @Operation(summary = "Get transaction summary", description = "Get a summary of user's transactions (income, expenses, balance)")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Summary retrieved successfully"),
            @ApiResponse(responseCode = "404", description = "User not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public ResponseEntity<Map<String, Object>> getUserTransactionSummary(@PathVariable Long userId) {
        Map<String, Object> response = transactionService.getUserTransactionSummary(userId);
        return ResponseEntity.ok(response);
    }

    // Category Endpoints
    @PostMapping("/categories")
    @Operation(summary = "Create category", description = "Create a new transaction category")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Category created successfully"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
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
    @Operation(summary = "Get all categories", description = "Retrieve all transaction categories")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Categories retrieved successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public ResponseEntity<Map<String, Object>> getAllCategories() {
        Map<String, Object> response = categoryService.getAllCategories();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/categories/{id}")
    @Operation(summary = "Get category by ID", description = "Retrieve a specific category by ID")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Category found"),
            @ApiResponse(responseCode = "404", description = "Category not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public ResponseEntity<CategoryResponse> getCategoryById(@PathVariable Long id) {
        CategoryResponse category = categoryService.getCategoryById(id);
        if (category != null) {
            return ResponseEntity.ok(category);
        }
        return ResponseEntity.notFound().build();
    }

    @PutMapping("/categories/{id}")
    @Operation(summary = "Update category", description = "Update an existing transaction category")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Category updated successfully"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "Category not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
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
    @Operation(summary = "Delete category", description = "Delete a transaction category by ID")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Category deleted successfully"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "Category not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
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
    @Operation(summary = "Initialize default categories", description = "Create default transaction categories if they don't exist")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Default categories initialized successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public ResponseEntity<Map<String, Object>> initializeDefaultCategories() {
        Map<String, Object> response = categoryService.initializeDefaultCategories();
        return ResponseEntity.ok(response);
    }
}