package com.privacyos.dto.response;
import com.privacyos.entity.RiskLevel;
import lombok.Builder;
import java.time.Instant;
import java.util.UUID;
@Builder
public record UserResponse(UUID id,String email,String fullName,String avatarUrl,boolean emailVerified,int privacyScore,RiskLevel riskLevel,String provider,String role,Instant createdAt){}
