package com.privacyos.entity;
import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.UUID;

@Entity @Table(name="privacy_score_history") @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class PrivacyScoreHistory {
    @Id @GeneratedValue(strategy=GenerationType.UUID) private UUID id;
    @ManyToOne(fetch=FetchType.LAZY) @JoinColumn(name="user_id",nullable=false) private User user;
    @Column(nullable=false) private int score;
    @Column(name="risk_level") @Enumerated(EnumType.STRING) private RiskLevel riskLevel;
    @Column(name="recorded_at") private Instant recordedAt=Instant.now();
}