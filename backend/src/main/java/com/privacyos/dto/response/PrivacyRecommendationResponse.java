package com.privacyos.dto.response;
import com.privacyos.entity.RiskLevel;
import lombok.Builder;
import java.time.Instant;
import java.util.UUID;
@Builder
public record PrivacyRecommendationResponse(UUID id,String type,RiskLevel priority,String title,String description,String actionLabel,String actionUrl,int expectedScoreImprovement,String status,UUID relatedAccountId,String relatedAccountProvider,Instant createdAt){}
