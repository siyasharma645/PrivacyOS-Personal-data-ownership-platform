package com.privacyos.repository;
import com.privacyos.entity.ConnectedAccount;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.*;
@Repository
public interface ConnectedAccountRepository extends JpaRepository<ConnectedAccount,UUID> {
    List<ConnectedAccount> findByUserIdOrderByCreatedAtDesc(UUID userId);
    Optional<ConnectedAccount> findByUserIdAndProvider(UUID userId,String provider);
    boolean existsByUserIdAndProviderAndProviderUserId(UUID userId,String provider,String providerUserId);
    long countByUserId(UUID userId);
}