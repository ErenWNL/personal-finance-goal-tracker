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
import java.util.Map;
import java.util.Optional;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    public Map<String, Object> register(RegisterRequest request) {
        Map<String, Object> response = new HashMap<>();

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