package com.privacyos.repository;
import com.privacyos.entity.PrivacyEvent;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.UUID;
@Repository
public interface PrivacyEventRepository extends JpaRepository<PrivacyEvent,UUID> {
    Page<PrivacyEvent> findByUserIdOrderByCreatedAtDesc(UUID userId,Pageable pageable);
}