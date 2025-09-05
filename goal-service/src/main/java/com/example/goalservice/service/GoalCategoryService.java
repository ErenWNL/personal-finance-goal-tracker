package com.example.goalservice.service;

import com.example.goalservice.dto.request.GoalCategoryRequest;
import com.example.goalservice.dto.response.GoalCategoryResponse;
import com.example.goalservice.entity.GoalCategory;
import com.example.goalservice.repository.GoalCategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class GoalCategoryService {

    @Autowired
    private GoalCategoryRepository categoryRepository;

    public Map<String, Object> createCategory(GoalCategoryRequest request) {
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
        GoalCategory category = new GoalCategory();
        category.setName(request.getName());
        category.setDescription(request.getDescription());
        category.setColorCode(request.getColorCode() != null ? request.getColorCode() : "#3B82F6");

        GoalCategory savedCategory = categoryRepository.save(category);
        GoalCategoryResponse categoryResponse = convertToCategoryResponse(savedCategory);

        response.put("success", true);
        response.put("message", "Goal category created successfully");
        response.put("category", categoryResponse);

        return response;
    }

    public Map<String, Object> getAllCategories() {
        Map<String, Object> response = new HashMap<>();

        List<GoalCategory> categories = categoryRepository.findAll();
        List<GoalCategoryResponse> categoryResponses = categories.stream()
                .map(this::convertToCategoryResponse)
                .toList();

        response.put("success", true);
        response.put("message", "Categories retrieved successfully");
        response.put("categories", categoryResponses);
        response.put("count", categoryResponses.size());

        return response;
    }

    public GoalCategoryResponse getCategoryById(Long id) {
        Optional<GoalCategory> categoryOpt = categoryRepository.findById(id);
        return categoryOpt.map(this::convertToCategoryResponse).orElse(null);
    }

    public Map<String, Object> updateCategory(Long id, GoalCategoryRequest request) {
        Map<String, Object> response = new HashMap<>();

        Optional<GoalCategory> categoryOpt = categoryRepository.findById(id);
        if (categoryOpt.isEmpty()) {
            response.put("success", false);
            response.put("message", "Category not found");
            return response;
        }

        GoalCategory category = categoryOpt.get();

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

        GoalCategory updatedCategory = categoryRepository.save(category);
        GoalCategoryResponse categoryResponse = convertToCategoryResponse(updatedCategory);

        response.put("success", true);
        response.put("message", "Category updated successfully");
        response.put("category", categoryResponse);

        return response;
    }

    public Map<String, Object> deleteCategory(Long id) {
        Map<String, Object> response = new HashMap<>();

        Optional<GoalCategory> categoryOpt = categoryRepository.findById(id);
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

    private GoalCategoryResponse convertToCategoryResponse(GoalCategory category) {
        GoalCategoryResponse response = new GoalCategoryResponse();
        response.setId(category.getId());
        response.setName(category.getName());
        response.setDescription(category.getDescription());
        response.setColorCode(category.getColorCode());
        response.setCreatedAt(category.getCreatedAt());
        return response;
    }
}