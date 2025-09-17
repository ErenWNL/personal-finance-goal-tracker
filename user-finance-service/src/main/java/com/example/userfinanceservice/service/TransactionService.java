package com.example.userfinanceservice.service;

import com.example.userfinanceservice.client.InsightServiceClient;
import com.example.userfinanceservice.dto.request.TransactionRequest;
import com.example.userfinanceservice.dto.response.CategoryResponse;
import com.example.userfinanceservice.dto.response.TransactionResponse;
import com.example.userfinanceservice.entity.Transaction;
import com.example.userfinanceservice.entity.TransactionCategory;
import com.example.userfinanceservice.repository.TransactionRepository;
import com.example.userfinanceservice.repository.TransactionCategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class TransactionService {

    @Autowired
    private TransactionRepository transactionRepository;

    @Autowired
    private TransactionCategoryRepository categoryRepository;

    @Autowired
    private InsightServiceClient insightServiceClient;

    public Map<String, Object> createTransaction(TransactionRequest request) {
        Map<String, Object> response = new HashMap<>();

        // Validation
        if (request.getUserId() == null) {
            response.put("success", false);
            response.put("message", "User ID is required");
            return response;
        }

        if (request.getAmount() == null || request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            response.put("success", false);
            response.put("message", "Amount must be greater than zero");
            return response;
        }

        if (request.getDescription() == null || request.getDescription().trim().isEmpty()) {
            response.put("success", false);
            response.put("message", "Description is required");
            return response;
        }

        if (request.getCategoryId() == null) {
            response.put("success", false);
            response.put("message", "Category is required");
            return response;
        }

        // Check if category exists
        Optional<TransactionCategory> categoryOpt = categoryRepository.findById(request.getCategoryId());
        if (categoryOpt.isEmpty()) {
            response.put("success", false);
            response.put("message", "Category not found");
            return response;
        }

        // Create transaction
        Transaction transaction = new Transaction();
        transaction.setUserId(request.getUserId());
        transaction.setAmount(request.getAmount());
        transaction.setDescription(request.getDescription());
        transaction.setCategory(categoryOpt.get());
        transaction.setType(request.getType() != null ? request.getType() : Transaction.TransactionType.EXPENSE);
        transaction.setTransactionDate(request.getTransactionDate() != null ? request.getTransactionDate() : LocalDate.now());
        transaction.setNotes(request.getNotes());

        Transaction savedTransaction = transactionRepository.save(transaction);

        // Notify Insight Service about new transaction
        try {
            insightServiceClient.notifyTransactionCreated(savedTransaction);
        } catch (Exception e) {
            System.err.println("Failed to notify Insight Service: " + e.getMessage());
        }

        TransactionResponse transactionResponse = convertToTransactionResponse(savedTransaction);

        response.put("success", true);
        response.put("message", "Transaction created successfully");
        response.put("transaction", transactionResponse);

        return response;
    }

    public Map<String, Object> getAllTransactions() {
        Map<String, Object> response = new HashMap<>();

        List<Transaction> transactions = transactionRepository.findAll();
        List<TransactionResponse> transactionResponses = transactions.stream()
                .map(this::convertToTransactionResponse)
                .toList();

        response.put("success", true);
        response.put("message", "Transactions retrieved successfully");
        response.put("transactions", transactionResponses);
        response.put("count", transactionResponses.size());

        return response;
    }

    public Map<String, Object> getTransactionsByUserId(Long userId) {
        Map<String, Object> response = new HashMap<>();

        List<Transaction> transactions = transactionRepository.findByUserIdOrderByTransactionDateDesc(userId);
        List<TransactionResponse> transactionResponses = transactions.stream()
                .map(this::convertToTransactionResponse)
                .toList();

        response.put("success", true);
        response.put("message", "User transactions retrieved successfully");
        response.put("transactions", transactionResponses);
        response.put("count", transactionResponses.size());

        return response;
    }

    public TransactionResponse getTransactionById(Long id) {
        Optional<Transaction> transactionOpt = transactionRepository.findById(id);
        return transactionOpt.map(this::convertToTransactionResponse).orElse(null);
    }

    public Map<String, Object> updateTransaction(Long id, TransactionRequest request) {
        Map<String, Object> response = new HashMap<>();

        Optional<Transaction> transactionOpt = transactionRepository.findById(id);
        if (transactionOpt.isEmpty()) {
            response.put("success", false);
            response.put("message", "Transaction not found");
            return response;
        }

        Transaction transaction = transactionOpt.get();

        // Update fields
        if (request.getAmount() != null) {
            transaction.setAmount(request.getAmount());
        }
        if (request.getDescription() != null) {
            transaction.setDescription(request.getDescription());
        }
        if (request.getCategoryId() != null) {
            Optional<TransactionCategory> categoryOpt = categoryRepository.findById(request.getCategoryId());
            if (categoryOpt.isPresent()) {
                transaction.setCategory(categoryOpt.get());
            }
        }
        if (request.getType() != null) {
            transaction.setType(request.getType());
        }
        if (request.getTransactionDate() != null) {
            transaction.setTransactionDate(request.getTransactionDate());
        }
        if (request.getNotes() != null) {
            transaction.setNotes(request.getNotes());
        }

        Transaction updatedTransaction = transactionRepository.save(transaction);

        // Notify Insight Service about updated transaction
        try {
            insightServiceClient.notifyTransactionUpdated(updatedTransaction);
        } catch (Exception e) {
            System.err.println("Failed to notify Insight Service about update: " + e.getMessage());
        }

        TransactionResponse transactionResponse = convertToTransactionResponse(updatedTransaction);

        response.put("success", true);
        response.put("message", "Transaction updated successfully");
        response.put("transaction", transactionResponse);

        return response;
    }

    public Map<String, Object> deleteTransaction(Long id) {
        Map<String, Object> response = new HashMap<>();

        Optional<Transaction> transactionOpt = transactionRepository.findById(id);
        if (transactionOpt.isEmpty()) {
            response.put("success", false);
            response.put("message", "Transaction not found");
            return response;
        }

        Transaction transaction = transactionOpt.get();
        Long userId = transaction.getUserId();

        transactionRepository.deleteById(id);

        // Notify Insight Service about deleted transaction
        try {
            insightServiceClient.notifyTransactionDeleted(id, userId);
        } catch (Exception e) {
            System.err.println("Failed to notify Insight Service about deletion: " + e.getMessage());
        }

        response.put("success", true);
        response.put("message", "Transaction deleted successfully");

        return response;
    }

    public Map<String, Object> getUserTransactionSummary(Long userId) {
        Map<String, Object> response = new HashMap<>();

        BigDecimal totalIncome = transactionRepository.getTotalAmountByUserIdAndType(userId, "INCOME");
        BigDecimal totalExpense = transactionRepository.getTotalAmountByUserIdAndType(userId, "EXPENSE");

        if (totalIncome == null) totalIncome = BigDecimal.ZERO;
        if (totalExpense == null) totalExpense = BigDecimal.ZERO;

        BigDecimal balance = totalIncome.subtract(totalExpense);

        response.put("success", true);
        response.put("message", "Transaction summary retrieved successfully");
        response.put("totalIncome", totalIncome);
        response.put("totalExpense", totalExpense);
        response.put("balance", balance);

        return response;
    }

    private TransactionResponse convertToTransactionResponse(Transaction transaction) {
        TransactionResponse response = new TransactionResponse();
        response.setId(transaction.getId());
        response.setUserId(transaction.getUserId());
        response.setAmount(transaction.getAmount());
        response.setDescription(transaction.getDescription());
        response.setType(transaction.getType());
        response.setTransactionDate(transaction.getTransactionDate());
        response.setNotes(transaction.getNotes());
        response.setCreatedAt(transaction.getCreatedAt());

        // Convert category
        if (transaction.getCategory() != null) {
            CategoryResponse categoryResponse = new CategoryResponse();
            categoryResponse.setId(transaction.getCategory().getId());
            categoryResponse.setName(transaction.getCategory().getName());
            categoryResponse.setDescription(transaction.getCategory().getDescription());
            categoryResponse.setColorCode(transaction.getCategory().getColorCode());
            categoryResponse.setIsDefault(transaction.getCategory().getIsDefault());
            categoryResponse.setCreatedAt(transaction.getCategory().getCreatedAt());
            response.setCategory(categoryResponse);
        }

        return response;
    }
}