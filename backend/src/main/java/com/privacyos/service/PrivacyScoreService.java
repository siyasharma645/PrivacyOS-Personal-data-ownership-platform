package com.privacyos.service;
import com.privacyos.dto.response.*;
import com.privacyos.entity.*;
import com.privacyos.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j @Service @RequiredArgsConstructor
public class PrivacyScoreService {
    private final UserRepository userRepository;
    private final ConnectedAccountRepository accountRepository;
    private final PermissionRepository permissionRepository;
    private final BreachRecordRepository breachRepository;
    private final PrivacyScoreHistoryRepository historyRepository;
    private static final DateTimeFormatter FMT=DateTimeFormatter.ofPattern("MMM d").withZone(ZoneId.systemDefault());

    @Cacheable(value="privacy-score",key="#userId")
    @Transactional(readOnly=true)
    public PrivacyScoreResponse getScore(UUID userId){
        var accounts=accountRepository.findByUserIdOrderByCreatedAtDesc(userId);
        var perms=permissionRepository.findByAccountUserIdOrderByRiskLevelDesc(userId);
        long breaches=breachRepository.countByUserIdAndRemediatedAtIsNull(userId);
        int p1=calcPermPenalty(perms),p2=(int)Math.min(100,breaches*12),p3=calcThirdParty(accounts),p4=calcSprawl(accounts.size()),p5=calcStaleness(accounts);
        int score=Math.max(0,Math.min(100,(int)(100-(p1*0.35+p2*0.25+p3*0.20+p4*0.12+p5*0.08))));
        var history=historyRepository.findByUserIdOrderByRecordedAtAsc(userId);
        var pts=history.stream().map(h->DashboardResponse.ScoreDataPoint.builder().date(FMT.format(h.getRecordedAt())).score(h.getScore()).build()).collect(Collectors.toList());
        return PrivacyScoreResponse.builder().score(score).riskLevel(RiskLevel.fromScore(score)).permissionPenalty(p1).breachPenalty(p2).thirdPartyPenalty(p3).sprawlPenalty(p4).stalenessPenalty(p5).breakdown(Map.of("permissions",p1,"breaches",p2,"thirdParty",p3,"sprawl",p4,"staleness",p5)).history(pts).build();
    }

    @CacheEvict(value="privacy-score",key="#userId")
    @Transactional
    public int recalculateAndPersist(UUID userId){
        var score=getScore(userId).score();
        userRepository.findById(userId).ifPresent(u->{u.setPrivacyScore(score);u.setRiskLevel(RiskLevel.fromScore(score));userRepository.save(u);});
        historyRepository.save(PrivacyScoreHistory.builder().user(userRepository.getReferenceById(userId)).score(score).riskLevel(RiskLevel.fromScore(score)).build());
        return score;
    }

    private int calcPermPenalty(List<Permission> perms){int t=0;for(var p:perms)t+=switch(p.getRiskLevel()){case CRITICAL->15;case HIGH->8;case MEDIUM->3;case LOW->1;};return Math.min(100,t);}
    private int calcThirdParty(List<ConnectedAccount> accounts){int p=0;for(var a:accounts)if(a.getScopes()!=null)p+=Math.min(15,a.getScopes().length*2);return Math.min(50,p);}
    private int calcSprawl(int n){if(n<=3)return 0;if(n<=7)return 15;if(n<=12)return 30;return 50;}
    private int calcStaleness(List<ConnectedAccount> accounts){int p=0;var ago=Instant.now().minus(30,java.time.temporal.ChronoUnit.DAYS);for(var a:accounts){if(a.getLastSyncedAt()!=null&&a.getLastSyncedAt().isBefore(ago))p+=10;if(a.getTokenExpiresAt()!=null&&a.getTokenExpiresAt().isBefore(Instant.now()))p+=8;}return Math.min(50,p);}
}
