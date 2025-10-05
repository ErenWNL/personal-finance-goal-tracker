package com.example.goalservice.controller;

import com.example.goalservice.dto.request.GoalCategoryRequest;
import com.example.goalservice.dto.response.GoalCategoryResponse;
import com.example.goalservice.service.GoalCategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/goals/categories")
public class GoalCategoryController {

    @Autowired
    private GoalCategoryService categoryService;

    @PostMapping
    public ResponseEntity<Map<String, Object>> createCategory(@RequestBody GoalCategoryRequest request) {
        Map<String, Object> response = categoryService.createCategory(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllCategories() {
        Map<String, Object> response = categoryService.getAllCategories();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<GoalCategoryResponse> getCategoryById(@PathVariable Long id) {
        GoalCategoryResponse category = categoryService.getCategoryById(id);
        if (category != null) {
            return ResponseEntity.ok(category);
        }
        return ResponseEntity.notFound().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateCategory(@PathVariable Long id, @RequestBody GoalCategoryRequest request) {
        Map<String, Object> response = categoryService.updateCategory(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteCategory(@PathVariable Long id) {
        Map<String, Object> response = categoryService.deleteCategory(id);
        return ResponseEntity.ok(response);
    }
}