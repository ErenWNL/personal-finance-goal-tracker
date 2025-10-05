package com.example.goalservice.controller;

import com.example.goalservice.dto.request.GoalRequest;
import com.example.goalservice.dto.response.GoalResponse;
import com.example.goalservice.service.GoalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/goals")
public class GoalController {

    @Autowired
    private GoalService goalService;

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Goal Service is running");
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createGoal(@RequestBody GoalRequest request) {
        Map<String, Object> response = goalService.createGoal(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllGoals() {
        Map<String, Object> response = goalService.getAllGoals();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> getGoalsByUserId(@PathVariable Long userId) {
        Map<String, Object> response = goalService.getGoalsByUserId(userId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<GoalResponse> getGoalById(@PathVariable Long id) {
        GoalResponse goal = goalService.getGoalById(id);
        if (goal != null) {
            return ResponseEntity.ok(goal);
        }
        return ResponseEntity.notFound().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateGoal(@PathVariable Long id, @RequestBody GoalRequest request) {
        Map<String, Object> response = goalService.updateGoal(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteGoal(@PathVariable Long id) {
        Map<String, Object> response = goalService.deleteGoal(id);
        return ResponseEntity.ok(response);
    }
}