package com.privacyos.repository;
import com.privacyos.entity.BreachRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.*;
@Repository
public interface BreachRecordRepository extends JpaRepository<BreachRecord,UUID> {
    List<BreachRecord> findByUserIdOrderByBreachDateDesc(UUID userId);
    boolean existsByUserIdAndBreachName(UUID userId,String breachName);
    long countByUserIdAndRemediatedAtIsNull(UUID userId);
}