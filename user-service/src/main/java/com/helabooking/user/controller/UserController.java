package com.helabooking.user.controller;

import com.helabooking.user.dto.AuthResponse;
import com.helabooking.user.dto.LoginRequest;
import com.helabooking.user.dto.RegisterRequest;
import com.helabooking.user.dto.UpdateUserRoleRequest;
import com.helabooking.user.dto.UserProfileResponse;
import com.helabooking.user.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@RequestBody RegisterRequest request) {
        return ResponseEntity.ok(userService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest request) {
        return ResponseEntity.ok(userService.login(request));
    }

    @GetMapping("/{userId}/profile")
    public ResponseEntity<UserProfileResponse> getProfile(@PathVariable Long userId) {
        return ResponseEntity.ok(userService.getProfile(userId));
    }

    @PutMapping("/{userId}/role")
    public ResponseEntity<UserProfileResponse> updateRole(
            @PathVariable Long userId, 
            @RequestBody UpdateUserRoleRequest request) {
        return ResponseEntity.ok(userService.updateRole(userId, request.getRole()));
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("User Service is running");
    }
}
/*
Example curl commands for the endpoints:

# Register
curl -s -X POST http://localhost:8080/api/users/register \
    -H "Content-Type: application/json" \
    -d '{"email":"user@example.com","password":"YourPassword123","name":"User Name"}'

# Login
curl -s -X POST http://localhost:8080/api/users/login \
    -H "Content-Type: application/json" \
    -d '{"email":"user@example.com","password":"YourPassword123"}'

# Health
curl -s http://localhost:8080/api/users/health

# Capture token from login response (requires jq)
TOKEN=$(curl -s -X POST http://localhost:8080/api/users/login \
    -H "Content-Type: application/json" \
    -d '{"email":"user@example.com","password":"YourPassword123"}' | jq -r '.token')

# Example authenticated request using the captured token
curl -s http://localhost:8080/api/users/health \
    -H "Authorization: Bearer $TOKEN"
*/


