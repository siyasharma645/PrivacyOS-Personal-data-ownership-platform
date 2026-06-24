package com.privacyos.dto.response;
import lombok.Builder;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;
@Builder
public record BreachRecordResponse(UUID id,String breachName,String title,String domain,LocalDate breachDate,String[] dataClasses,Long pwnCount,String description,String logoPath,boolean verified,boolean sensitive,boolean remediated,Instant createdAt){}
