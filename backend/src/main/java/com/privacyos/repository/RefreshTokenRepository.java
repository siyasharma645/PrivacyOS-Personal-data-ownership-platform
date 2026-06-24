package com.privacyos.repository;
import com.privacyos.entity.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.*;
@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken,UUID> {
    Optional<RefreshToken> findByTokenAndRevokedFalse(String token);
    @Modifying @Query("UPDATE RefreshToken r SET r.revoked=true WHERE r.user.id=:userId")
    void revokeAllUserTokens(UUID userId);
}