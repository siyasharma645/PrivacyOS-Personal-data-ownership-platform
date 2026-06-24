package com.privacyos.dto.response;
import lombok.Builder;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
@Builder
public record ConnectedAccountResponse(UUID id,String provider,String providerEmail,String displayName,String avatarUrl,String status,int riskContribution,String[] scopes,List<PermissionResponse> permissions,int permissionCount,int highRiskCount,Instant lastSyncedAt,Instant createdAt){}
