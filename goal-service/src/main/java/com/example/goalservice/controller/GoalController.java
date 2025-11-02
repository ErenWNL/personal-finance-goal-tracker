package com.example.goalservice.controller;

import com.example.goalservice.dto.request.GoalRequest;
import com.example.goalservice.dto.response.GoalResponse;
import com.example.goalservice.service.GoalService;
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
@RequestMapping("/goals")
@Tag(name = "Goals", description = "Financial goal management endpoints")
public class GoalController {

    @Autowired
    private GoalService goalService;

    @GetMapping("/health")
    @Operation(summary = "Health check", description = "Check if the goal service is running")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Goal Service is running");
    }

    @PostMapping
    @Operation(summary = "Create goal", description = "Create a new financial goal")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Goal created successfully"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public ResponseEntity<Map<String, Object>> createGoal(@RequestBody GoalRequest request) {
        Map<String, Object> response = goalService.createGoal(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    @Operation(summary = "Get all goals", description = "Retrieve all financial goals from the system")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Goals retrieved successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public ResponseEntity<Map<String, Object>> getAllGoals() {
        Map<String, Object> response = goalService.getAllGoals();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}")
    @Operation(summary = "Get user goals", description = "Retrieve all financial goals for a specific user")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User goals retrieved successfully"),
            @ApiResponse(responseCode = "404", description = "User not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public ResponseEntity<Map<String, Object>> getGoalsByUserId(@PathVariable Long userId) {
        Map<String, Object> response = goalService.getGoalsByUserId(userId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get goal by ID", description = "Retrieve a specific goal by ID")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Goal found"),
            @ApiResponse(responseCode = "404", description = "Goal not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public ResponseEntity<GoalResponse> getGoalById(@PathVariable Long id) {
        GoalResponse goal = goalService.getGoalById(id);
        if (goal != null) {
            return ResponseEntity.ok(goal);
        }
        return ResponseEntity.notFound().build();
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update goal", description = "Update an existing financial goal")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Goal updated successfully"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "Goal not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public ResponseEntity<Map<String, Object>> updateGoal(@PathVariable Long id, @RequestBody GoalRequest request) {
        Map<String, Object> response = goalService.updateGoal(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete goal", description = "Delete a financial goal by ID")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Goal deleted successfully"),
            @ApiResponse(responseCode = "404", description = "Goal not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public ResponseEntity<Map<String, Object>> deleteGoal(@PathVariable Long id) {
        Map<String, Object> response = goalService.deleteGoal(id);
        return ResponseEntity.ok(response);
    }
}