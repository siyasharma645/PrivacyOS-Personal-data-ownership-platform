package com.privacyos.service;
import com.privacyos.dto.response.PrivacyRecommendationResponse;
import com.privacyos.entity.*;
import com.privacyos.exception.NotFoundException;
import com.privacyos.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

@Service @RequiredArgsConstructor
public class RecommendationService {
    private final PrivacyRecommendationRepository recommendationRepository;
    private final ConnectedAccountRepository accountRepository;
    private final PermissionRepository permissionRepository;
    private final BreachRecordRepository breachRepository;
    private final UserRepository userRepository;
    private final PrivacyScoreService scoreService;

    @Transactional(readOnly=true)
    public List<PrivacyRecommendationResponse> getRecommendations(UUID userId){return recommendationRepository.findByUserIdOrderByPriorityDescCreatedAtDesc(userId).stream().map(this::toResponse).collect(Collectors.toList());}

    @Transactional
    public PrivacyRecommendationResponse complete(UUID id,UUID userId){var r=find(id,userId);r.setStatus("COMPLETED");r.setCompletedAt(Instant.now());scoreService.recalculateAndPersist(userId);return toResponse(recommendationRepository.save(r));}

    @Transactional
    public PrivacyRecommendationResponse dismiss(UUID id,UUID userId){var r=find(id,userId);r.setStatus("DISMISSED");return toResponse(recommendationRepository.save(r));}

    @Transactional
    public void generateRecommendations(UUID userId){
        User user=userRepository.findById(userId).orElseThrow();
        var accounts=accountRepository.findByUserIdOrderByCreatedAtDesc(userId);
        var highRisk=permissionRepository.findByAccountUserIdAndRiskLevelOrderByRiskLevelDesc(userId,RiskLevel.HIGH);
        var breaches=breachRepository.findByUserIdOrderByBreachDateDesc(userId);
        List<PrivacyRecommendation> newRecs=new ArrayList<>();
        for(var p:highRisk){if(p.isRevocable())newRecs.add(PrivacyRecommendation.builder().user(user).type("REVOKE_PERMISSION").priority(RiskLevel.HIGH).title("Revoke High-Risk Permission: "+p.getDisplayName()).description("This permission grants "+p.getDescription()+". Consider revoking if not needed.").actionLabel("Review Permission").expectedScoreImprovement(8).relatedAccount(p.getAccount()).relatedPermission(p).build());}
        for(var b:breaches){if(b.getRemediatedAt()==null)newRecs.add(PrivacyRecommendation.builder().user(user).type("REMEDIATE_BREACH").priority(RiskLevel.CRITICAL).title("Resolve "+b.getTitle()+" Breach").description("Your data was exposed in the "+b.getTitle()+" breach. Change your password and enable 2FA.").actionLabel("Learn More").expectedScoreImprovement(10).build());}
        if(accounts.size()>5)newRecs.add(PrivacyRecommendation.builder().user(user).type("REDUCE_SPRAWL").priority(RiskLevel.MEDIUM).title("Reduce Connected Account Sprawl").description("You have "+accounts.size()+" connected accounts. Disconnecting unused ones reduces your attack surface.").actionLabel("Review Accounts").expectedScoreImprovement(5).build());
        if(!newRecs.isEmpty())recommendationRepository.saveAll(newRecs);
    }

    private PrivacyRecommendation find(UUID id,UUID userId){return recommendationRepository.findById(id).filter(r->r.getUser().getId().equals(userId)).orElseThrow(()->new NotFoundException("Recommendation not found"));}

    public PrivacyRecommendationResponse toResponse(PrivacyRecommendation r){return PrivacyRecommendationResponse.builder().id(r.getId()).type(r.getType()).priority(r.getPriority()).title(r.getTitle()).description(r.getDescription()).actionLabel(r.getActionLabel()).actionUrl(r.getActionUrl()).expectedScoreImprovement(r.getExpectedScoreImprovement()).status(r.getStatus()).relatedAccountId(r.getRelatedAccount()!=null?r.getRelatedAccount().getId():null).relatedAccountProvider(r.getRelatedAccount()!=null?r.getRelatedAccount().getProvider():null).createdAt(r.getCreatedAt()).build();}
}
