package com.privacyos.repository;
import com.privacyos.entity.PrivacyScoreHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.*;
@Repository
public interface PrivacyScoreHistoryRepository extends JpaRepository<PrivacyScoreHistory,UUID> {
    List<PrivacyScoreHistory> findTop30ByUserIdOrderByRecordedAtDesc(UUID userId);
    List<PrivacyScoreHistory> findByUserIdOrderByRecordedAtAsc(UUID userId);
}