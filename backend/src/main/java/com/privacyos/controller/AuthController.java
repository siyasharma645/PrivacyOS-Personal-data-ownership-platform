package com.privacyos.controller;
import com.privacyos.dto.request.*;
import com.privacyos.dto.response.*;
import com.privacyos.entity.User;
import com.privacyos.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController @RequestMapping("/api/v1/auth") @RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;
    @PostMapping("/register") public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest r){return ResponseEntity.status(HttpStatus.CREATED).body(authService.register(r));}
    @PostMapping("/login") public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest r){return ResponseEntity.ok(authService.login(r));}
    @PostMapping("/refresh") public ResponseEntity<AuthResponse> refresh(@RequestBody Map<String,String> b){return ResponseEntity.ok(authService.refreshToken(b.get("refreshToken")));}
    @PostMapping("/logout") public ResponseEntity<Void> logout(@AuthenticationPrincipal User u){authService.logout(u.getId());return ResponseEntity.noContent().build();}
    @GetMapping("/me") public ResponseEntity<UserResponse> me(@AuthenticationPrincipal User u){return ResponseEntity.ok(authService.toUserResponse(u));}
}
