package com.helabooking.user.dto;

import com.helabooking.user.model.UserRole;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileResponse {
    private Long id;
    private String username;
    private String email;
    private UserRole role;
    private Boolean active;
    private LocalDateTime createdAt;
}
