package com.privacyos.repository;
import com.privacyos.entity.Permission;
import com.privacyos.entity.RiskLevel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.*;
@Repository
public interface PermissionRepository extends JpaRepository<Permission,UUID> {
    List<Permission> findByAccountId(UUID accountId);
    List<Permission> findByAccountUserIdAndRiskLevelOrderByRiskLevelDesc(UUID userId,RiskLevel riskLevel);
    long countByAccountUserIdAndRiskLevel(UUID userId,RiskLevel riskLevel);
    List<Permission> findByAccountUserIdOrderByRiskLevelDesc(UUID userId);
}