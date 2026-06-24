package com.privacyos.dto.response;
import com.privacyos.entity.RiskLevel;
import lombok.Builder;
import java.util.List;
import java.util.Map;
@Builder
public record PrivacyScoreResponse(int score,RiskLevel riskLevel,int permissionPenalty,int breachPenalty,int thirdPartyPenalty,int sprawlPenalty,int stalenessPenalty,Map<String,Integer> breakdown,List<DashboardResponse.ScoreDataPoint> history){}
