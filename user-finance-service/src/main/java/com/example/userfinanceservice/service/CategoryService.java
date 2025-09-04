package com.example.userfinanceservice.service;

import com.example.userfinanceservice.dto.request.CategoryRequest;
import com.example.userfinanceservice.dto.response.CategoryResponse;
import com.example.userfinanceservice.entity.TransactionCategory;
import com.example.userfinanceservice.repository.TransactionCategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class CategoryService {

    @Autowired
    private TransactionCategoryRepository categoryRepository;

    public Map<String, Object> createCategory(CategoryRequest request) {
        Map<String, Object> response = new HashMap<>();

        // Validation
        if (request.getName() == null || request.getName().trim().isEmpty()) {
            response.put("success", false);
            response.put("message", "Category name is required");
            return response;
        }

        if (categoryRepository.existsByName(request.getName())) {
            response.put("success", false);
            response.put("message", "Category name already exists");
            return response;
        }

        // Create category
        TransactionCategory category = new TransactionCategory();
        category.setName(request.getName());
        category.setDescription(request.getDescription());
        category.setColorCode(request.getColorCode() != null ? request.getColorCode() : "#000000");
        category.setIsDefault(request.getIsDefault() != null ? request.getIsDefault() : false);

        TransactionCategory savedCategory = categoryRepository.save(category);
        CategoryResponse categoryResponse = convertToCategoryResponse(savedCategory);

        response.put("success", true);
        response.put("message", "Category created successfully");
        response.put("category", categoryResponse);

        return response;
    }

    public Map<String, Object> getAllCategories() {
        Map<String, Object> response = new HashMap<>();

        List<TransactionCategory> categories = categoryRepository.findAll();
        List<CategoryResponse> categoryResponses = categories.stream()
                .map(this::convertToCategoryResponse)
                .toList();

        response.put("success", true);
        response.put("message", "Categories retrieved successfully");
        response.put("categories", categoryResponses);
        response.put("count", categoryResponses.size());

        return response;
    }

    public CategoryResponse getCategoryById(Long id) {
        Optional<TransactionCategory> categoryOpt = categoryRepository.findById(id);
        return categoryOpt.map(this::convertToCategoryResponse).orElse(null);
    }

    public Map<String, Object> updateCategory(Long id, CategoryRequest request) {
        Map<String, Object> response = new HashMap<>();

        Optional<TransactionCategory> categoryOpt = categoryRepository.findById(id);
        if (categoryOpt.isEmpty()) {
            response.put("success", false);
            response.put("message", "Category not found");
            return response;
        }

        TransactionCategory category = categoryOpt.get();

        // Update fields
        if (request.getName() != null && !request.getName().trim().isEmpty()) {
            category.setName(request.getName());
        }
        if (request.getDescription() != null) {
            category.setDescription(request.getDescription());
        }
        if (request.getColorCode() != null) {
            category.setColorCode(request.getColorCode());
        }
        if (request.getIsDefault() != null) {
            category.setIsDefault(request.getIsDefault());
        }

        TransactionCategory updatedCategory = categoryRepository.save(category);
        CategoryResponse categoryResponse = convertToCategoryResponse(updatedCategory);

        response.put("success", true);
        response.put("message", "Category updated successfully");
        response.put("category", categoryResponse);

        return response;
    }

    public Map<String, Object> deleteCategory(Long id) {
        Map<String, Object> response = new HashMap<>();

        Optional<TransactionCategory> categoryOpt = categoryRepository.findById(id);
        if (categoryOpt.isEmpty()) {
            response.put("success", false);
            response.put("message", "Category not found");
            return response;
        }

        categoryRepository.deleteById(id);

        response.put("success", true);
        response.put("message", "Category deleted successfully");

        return response;
    }

    public Map<String, Object> initializeDefaultCategories() {
        Map<String, Object> response = new HashMap<>();

        // Check if default categories already exist
        List<TransactionCategory> existingDefaults = categoryRepository.findByIsDefaultTrue();
        if (!existingDefaults.isEmpty()) {
            response.put("success", true);
            response.put("message", "Default categories already exist");
            return response;
        }

        // Create default categories
        String[] defaultCategories = {
                "Food & Dining", "Transportation", "Shopping", "Entertainment",
                "Bills & Utilities", "Healthcare", "Education", "Travel",
                "Salary", "Business", "Investment", "Other"
        };

        String[] colors = {
                "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4",
                "#FFEAA7", "#DDA0DD", "#98D8C8", "#F7DC6F",
                "#82E0AA", "#85C1E9", "#F8C471", "#D7DBDD"
        };

        for (int i = 0; i < defaultCategories.length; i++) {
            TransactionCategory category = new TransactionCategory();
            category.setName(defaultCategories[i]);
            category.setDescription("Default " + defaultCategories[i] + " category");
            category.setColorCode(colors[i % colors.length]);
            category.setIsDefault(true);
            categoryRepository.save(category);
        }

        response.put("success", true);
        response.put("message", "Default categories initialized successfully");
        response.put("count", defaultCategories.length);

        return response;
    }

    private CategoryResponse convertToCategoryResponse(TransactionCategory category) {
        CategoryResponse response = new CategoryResponse();
        response.setId(category.getId());
        response.setName(category.getName());
        response.setDescription(category.getDescription());
        response.setColorCode(category.getColorCode());
        response.setIsDefault(category.getIsDefault());
        response.setCreatedAt(category.getCreatedAt());
        return response;
    }
}