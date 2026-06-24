package com.privacyos.dto.response;
import com.privacyos.entity.RiskLevel;
import lombok.Builder;
import java.util.List;
@Builder
public record DashboardResponse(int privacyScore,int previousScore,int scoreChange,RiskLevel riskLevel,long connectedAccounts,long activePermissions,long highRiskPermissions,long unresolvedBreaches,long pendingRecommendations,List<ScoreDataPoint> scoreHistory,List<ConnectedAccountResponse> recentAccounts,List<PrivacyRecommendationResponse> topRecommendations){
  @Builder public record ScoreDataPoint(String date,int score){}
}
