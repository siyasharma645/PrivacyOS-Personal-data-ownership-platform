package com.privacyos.repository;
import com.privacyos.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.*;
@Repository
public interface UserRepository extends JpaRepository<User,UUID> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    Optional<User> findByProviderAndProviderId(String provider,String providerId);
}