package com.privacyos.service;
import com.privacyos.dto.response.*;
import com.privacyos.entity.RiskLevel;
import com.privacyos.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service @RequiredArgsConstructor
public class DashboardService {
    private final UserRepository userRepository;
    private final ConnectedAccountRepository accountRepository;
    private final PermissionRepository permissionRepository;
    private final BreachRecordRepository breachRepository;
    private final PrivacyRecommendationRepository recommendationRepository;
    private final PrivacyScoreHistoryRepository historyRepository;
    private final PrivacyScoreService scoreService;
    private final AccountService accountService;
    private final RecommendationService recommendationService;
    private static final DateTimeFormatter FMT=DateTimeFormatter.ofPattern("MMM d").withZone(ZoneId.systemDefault());

    @Transactional(readOnly=true)
    public DashboardResponse getDashboard(UUID userId){
        var user=userRepository.findById(userId).orElseThrow();
        long accounts=accountRepository.countByUserId(userId);
        long highRisk=permissionRepository.countByAccountUserIdAndRiskLevel(userId,RiskLevel.HIGH)+permissionRepository.countByAccountUserIdAndRiskLevel(userId,RiskLevel.CRITICAL);
        long allPerms=permissionRepository.findByAccountUserIdOrderByRiskLevelDesc(userId).size();
        long breaches=breachRepository.countByUserIdAndRemediatedAtIsNull(userId);
        long pending=recommendationRepository.countByUserIdAndStatus(userId,"PENDING");
        var history=historyRepository.findByUserIdOrderByRecordedAtAsc(userId);
        var pts=history.stream().map(h->DashboardResponse.ScoreDataPoint.builder().date(FMT.format(h.getRecordedAt())).score(h.getScore()).build()).collect(Collectors.toList());
        int prev=history.size()>=2?history.get(history.size()-2).getScore():user.getPrivacyScore();
        var recentAccts=accountRepository.findByUserIdOrderByCreatedAtDesc(userId).stream().limit(3).map(accountService::toResponse).toList();
        var topRecs=recommendationRepository.findByUserIdAndStatusOrderByPriorityDesc(userId,"PENDING").stream().limit(3).map(recommendationService::toResponse).toList();
        return DashboardResponse.builder().privacyScore(user.getPrivacyScore()).previousScore(prev).scoreChange(user.getPrivacyScore()-prev).riskLevel(user.getRiskLevel()).connectedAccounts(accounts).activePermissions(allPerms).highRiskPermissions(highRisk).unresolvedBreaches(breaches).pendingRecommendations(pending).scoreHistory(pts).recentAccounts(recentAccts).topRecommendations(topRecs).build();
    }
}
