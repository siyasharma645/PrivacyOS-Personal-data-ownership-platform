package com.privacyos.dto.response;
import com.privacyos.entity.EventSeverity;
import lombok.Builder;
import java.time.Instant;
import java.util.UUID;
@Builder
public record PrivacyEventResponse(UUID id,String eventType,String entityType,String title,String description,EventSeverity severity,Integer scoreBefore,Integer scoreAfter,Instant createdAt){}
