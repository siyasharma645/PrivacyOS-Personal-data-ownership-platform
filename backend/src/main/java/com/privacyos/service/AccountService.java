package com.privacyos.service;
import com.privacyos.dto.response.*;
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
public class AccountService {
    private final ConnectedAccountRepository accountRepository;
    private final PermissionRepository permissionRepository;
    private final PrivacyScoreService scoreService;
    private final PrivacyEventService eventService;

    @Transactional(readOnly=true)
    public List<ConnectedAccountResponse> getAccounts(UUID userId){return accountRepository.findByUserIdOrderByCreatedAtDesc(userId).stream().map(this::toResponse).collect(Collectors.toList());}

    @Transactional(readOnly=true)
    public ConnectedAccountResponse getAccount(UUID id,UUID userId){return toResponse(accountRepository.findById(id).filter(a->a.getUser().getId().equals(userId)).orElseThrow(()->new NotFoundException("Account not found")));}

    @Transactional
    public void disconnectAccount(UUID id,UUID userId){
        var a=accountRepository.findById(id).filter(acc->acc.getUser().getId().equals(userId)).orElseThrow(()->new NotFoundException("Account not found"));
        eventService.recordEvent(userId,"ACCOUNT_DISCONNECTED",id,"connected_account","Account Disconnected: "+a.getProvider(),"Disconnected "+a.getProvider(),EventSeverity.INFO,null,null);
        accountRepository.delete(a);scoreService.recalculateAndPersist(userId);
    }

    @Transactional
    public ConnectedAccountResponse syncAccount(UUID id,UUID userId){
        var a=accountRepository.findById(id).filter(acc->acc.getUser().getId().equals(userId)).orElseThrow(()->new NotFoundException("Account not found"));
        a.setLastSyncedAt(Instant.now());scoreService.recalculateAndPersist(userId);return toResponse(accountRepository.save(a));
    }

    @Transactional(readOnly=true)
    public List<PermissionResponse> getPermissions(UUID accountId,UUID userId){
        return accountRepository.findById(accountId).filter(a->a.getUser().getId().equals(userId)).orElseThrow(()->new NotFoundException("Account not found")).getPermissions().stream().filter(p->p.getRevokedAt()==null).map(this::toPermResponse).collect(Collectors.toList());
    }

    @Transactional
    public void revokePermission(UUID permId,UUID userId){
        var p=permissionRepository.findById(permId).filter(perm->perm.getAccount().getUser().getId().equals(userId)).orElseThrow(()->new NotFoundException("Permission not found"));
        p.setRevokedAt(Instant.now());permissionRepository.save(p);scoreService.recalculateAndPersist(userId);
        eventService.recordEvent(userId,"PERMISSION_REVOKED",permId,"permission","Permission Revoked: "+p.getDisplayName(),"Revoked "+p.getScopeName(),EventSeverity.INFO,null,null);
    }

    public ConnectedAccountResponse toResponse(ConnectedAccount a){
        var active=a.getPermissions().stream().filter(p->p.getRevokedAt()==null).toList();
        long hr=active.stream().filter(p->p.getRiskLevel()==RiskLevel.HIGH||p.getRiskLevel()==RiskLevel.CRITICAL).count();
        return ConnectedAccountResponse.builder().id(a.getId()).provider(a.getProvider()).providerEmail(a.getProviderEmail()).displayName(a.getDisplayName()).avatarUrl(a.getAvatarUrl()).status(a.getStatus()).riskContribution(a.getRiskContribution()).scopes(a.getScopes()).permissions(active.stream().map(this::toPermResponse).toList()).permissionCount(active.size()).highRiskCount((int)hr).lastSyncedAt(a.getLastSyncedAt()).createdAt(a.getCreatedAt()).build();
    }

    public PermissionResponse toPermResponse(Permission p){return PermissionResponse.builder().id(p.getId()).accountId(p.getAccount().getId()).scopeName(p.getScopeName()).displayName(p.getDisplayName()).description(p.getDescription()).riskLevel(p.getRiskLevel()).category(p.getCategory()).dataTypes(p.getDataTypes()).revocable(p.isRevocable()).sensitive(p.isSensitive()).grantedAt(p.getGrantedAt()).build();}
}
