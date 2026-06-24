package com.privacyos.dto.response;
import com.privacyos.entity.RiskLevel;
import lombok.Builder;
import java.time.Instant;
import java.util.UUID;
@Builder
public record PermissionResponse(UUID id,UUID accountId,String scopeName,String displayName,String description,RiskLevel riskLevel,String category,String[] dataTypes,boolean revocable,boolean sensitive,Instant grantedAt){}
