package com.privacyos.service;
import com.privacyos.dto.request.*;
import com.privacyos.dto.response.*;
import com.privacyos.entity.*;
import com.privacyos.exception.*;
import com.privacyos.repository.*;
import com.privacyos.security.JwtService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.Instant;
import java.util.UUID;

@Slf4j @Service @RequiredArgsConstructor
public class AuthService {
    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    @Value("${jwt.refresh-expiration}") private long refreshExpiration;

    @Transactional
    public AuthResponse register(RegisterRequest req) {
        if (userRepository.existsByEmail(req.email())) throw new ConflictException("Email already registered");
        User user=User.builder().email(req.email()).passwordHash(passwordEncoder.encode(req.password())).fullName(req.fullName()).privacyScore(75).riskLevel(RiskLevel.LOW).emailVerified(false).provider("LOCAL").build();
        return buildAuthResponse(userRepository.save(user));
    }

    @Transactional
    public AuthResponse login(LoginRequest req) {
        authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(req.email(),req.password()));
        return buildAuthResponse(userRepository.findByEmail(req.email()).orElseThrow(()->new UnauthorizedException("Invalid credentials")));
    }

    @Transactional
    public AuthResponse refreshToken(String tokenStr) {
        RefreshToken rt=refreshTokenRepository.findByTokenAndRevokedFalse(tokenStr).orElseThrow(()->new UnauthorizedException("Invalid refresh token"));
        if(rt.getExpiresAt().isBefore(Instant.now())){rt.setRevoked(true);refreshTokenRepository.save(rt);throw new UnauthorizedException("Refresh token expired");}
        User user=rt.getUser();rt.setRevoked(true);refreshTokenRepository.save(rt);
        return buildAuthResponse(user);
    }

    @Transactional
    public void logout(UUID userId){refreshTokenRepository.revokeAllUserTokens(userId);}

    private AuthResponse buildAuthResponse(User user){
        String accessToken=jwtService.generateToken(user);
        String refreshStr=UUID.randomUUID().toString();
        refreshTokenRepository.save(RefreshToken.builder().user(user).token(refreshStr).expiresAt(Instant.now().plusMillis(refreshExpiration)).build());
        return AuthResponse.builder().accessToken(accessToken).refreshToken(refreshStr).tokenType("Bearer").expiresIn(86400).user(toUserResponse(user)).build();
    }

    public UserResponse toUserResponse(User u){
        return UserResponse.builder().id(u.getId()).email(u.getEmail()).fullName(u.getFullName()).avatarUrl(u.getAvatarUrl()).emailVerified(u.isEmailVerified()).privacyScore(u.getPrivacyScore()).riskLevel(u.getRiskLevel()).provider(u.getProvider()).role(u.getRole()).createdAt(u.getCreatedAt()).build();
    }
}
