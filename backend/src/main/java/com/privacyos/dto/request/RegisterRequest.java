package com.privacyos.dto.request;
import jakarta.validation.constraints.*;
public record RegisterRequest(@NotBlank @Email String email,@NotBlank @Size(min=8) String password,@NotBlank @Size(min=2,max=100) String fullName){}
