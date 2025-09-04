package com.example.authenticationservice.service;

import com.example.authenticationservice.dto.request.LoginRequest;
import com.example.authenticationservice.dto.request.RegisterRequest;
import com.example.authenticationservice.dto.response.UserResponse;
import com.example.authenticationservice.entity.User;
import com.example.authenticationservice.repository.UserRepository;
import at.favre.lib.crypto.bcrypt.BCrypt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    public Map<String, Object> register(RegisterRequest request) {
        Map<String, Object> response = new HashMap<>();

        // Basic validation
        if (request.getEmail() == null || request.getEmail().trim().isEmpty()) {
            response.put("success", false);
            response.put("message", "Email is required");
            return response;
        }

        if (request.getPassword() == null || request.getPassword().length() < 6) {
            response.put("success", false);
            response.put("message", "Password must be at least 6 characters");
            return response;
        }

        if (request.getFirstName() == null || request.getFirstName().trim().isEmpty()) {
            response.put("success", false);
            response.put("message", "First name is required");
            return response;
        }

        if (request.getLastName() == null || request.getLastName().trim().isEmpty()) {
            response.put("success", false);
            response.put("message", "Last name is required");
            return response;
        }

        // Check if user already exists
        if (userRepository.existsByEmail(request.getEmail())) {
            response.put("success", false);
            response.put("message", "Email already registered");
            return response;
        }

        // Hash password
        String hashedPassword = BCrypt.withDefaults().hashToString(12, request.getPassword().toCharArray());

        // Create new user
        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword(hashedPassword);
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setPhone(request.getPhone());

        User savedUser = userRepository.save(user);

        // Convert to response
        UserResponse userResponse = convertToUserResponse(savedUser);

        response.put("success", true);
        response.put("message", "User registered successfully");
        response.put("user", userResponse);

        return response;
    }

    public Map<String, Object> login(LoginRequest request) {
        Map<String, Object> response = new HashMap<>();

        Optional<User> userOpt = userRepository.findByEmail(request.getEmail());

        if (userOpt.isEmpty()) {
            response.put("success", false);
            response.put("message", "Invalid email or password");
            return response;
        }

        User user = userOpt.get();

        // Verify password
        boolean isPasswordValid = BCrypt.verifyer().verify(request.getPassword().toCharArray(), user.getPassword()).verified;

        if (!isPasswordValid) {
            response.put("success", false);
            response.put("message", "Invalid email or password");
            return response;
        }

        // Update last login
        user.setLastLogin(LocalDateTime.now());
        userRepository.save(user);

        // Convert to response
        UserResponse userResponse = convertToUserResponse(user);

        response.put("success", true);
        response.put("message", "Login successful");
        response.put("user", userResponse);
        response.put("token", "jwt-token-here"); // We'll implement JWT later

        return response;
    }

    public UserResponse getUserById(Long id) {
        Optional<User> userOpt = userRepository.findById(id);
        return userOpt.map(this::convertToUserResponse).orElse(null);
    }

    public Map<String, Object> updateUser(Long id, RegisterRequest request) {
        Map<String, Object> response = new HashMap<>();

        Optional<User> userOpt = userRepository.findById(id);
        if (userOpt.isEmpty()) {
            response.put("success", false);
            response.put("message", "User not found");
            return response;
        }

        User user = userOpt.get();

        // Update user fields
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setPhone(request.getPhone());

        // Update password if provided
        if (request.getPassword() != null && !request.getPassword().isEmpty()) {
            String hashedPassword = BCrypt.withDefaults().hashToString(12, request.getPassword().toCharArray());
            user.setPassword(hashedPassword);
        }

        User updatedUser = userRepository.save(user);
        UserResponse userResponse = convertToUserResponse(updatedUser);

        response.put("success", true);
        response.put("message", "User updated successfully");
        response.put("user", userResponse);

        return response;
    }

    public Map<String, Object> deleteUser(Long id) {
        Map<String, Object> response = new HashMap<>();

        Optional<User> userOpt = userRepository.findById(id);
        if (userOpt.isEmpty()) {
            response.put("success", false);
            response.put("message", "User not found");
            return response;
        }

        userRepository.deleteById(id);

        response.put("success", true);
        response.put("message", "User deleted successfully");

        return response;
    }

    public Map<String, Object> getAllUsers() {
        Map<String, Object> response = new HashMap<>();

        List<User> users = userRepository.findAll();
        List<UserResponse> userResponses = users.stream()
                .map(this::convertToUserResponse)
                .toList();

        response.put("success", true);
        response.put("message", "Users retrieved successfully");
        response.put("users", userResponses);
        response.put("count", userResponses.size());

        return response;
    }

    private UserResponse convertToUserResponse(User user) {
        UserResponse response = new UserResponse();
        response.setId(user.getId());
        response.setEmail(user.getEmail());
        response.setFirstName(user.getFirstName());
        response.setLastName(user.getLastName());
        response.setPhone(user.getPhone());
        response.setIsActive(user.getIsActive());
        response.setCreatedAt(user.getCreatedAt());
        response.setLastLogin(user.getLastLogin());
        return response;
    }
}