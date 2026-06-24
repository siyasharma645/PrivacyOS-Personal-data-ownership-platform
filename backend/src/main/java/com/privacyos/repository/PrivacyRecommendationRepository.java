package com.privacyos.repository;
import com.privacyos.entity.PrivacyRecommendation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.*;
@Repository
public interface PrivacyRecommendationRepository extends JpaRepository<PrivacyRecommendation,UUID> {
    List<PrivacyRecommendation> findByUserIdAndStatusOrderByPriorityDesc(UUID userId,String status);
    List<PrivacyRecommendation> findByUserIdOrderByPriorityDescCreatedAtDesc(UUID userId);
    long countByUserIdAndStatus(UUID userId,String status);
}