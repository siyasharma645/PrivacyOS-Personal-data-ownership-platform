package com.privacyos.entity;
import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.UUID;

@Entity @Table(name="privacy_recommendations") @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class PrivacyRecommendation {
    @Id @GeneratedValue(strategy=GenerationType.UUID) private UUID id;
    @ManyToOne(fetch=FetchType.LAZY) @JoinColumn(name="user_id",nullable=false) private User user;
    @Column(name="type",nullable=false) private String type;
    @Column(name="priority") @Enumerated(EnumType.STRING) private RiskLevel priority=RiskLevel.MEDIUM;
    @Column(name="title",nullable=false) private String title;
    @Column(name="description",columnDefinition="TEXT") private String description;
    @Column(name="action_label") private String actionLabel;
    @Column(name="action_url") private String actionUrl;
    @Column(name="expected_score_improvement") private int expectedScoreImprovement=0;
    @ManyToOne(fetch=FetchType.LAZY) @JoinColumn(name="related_account_id") private ConnectedAccount relatedAccount;
    @ManyToOne(fetch=FetchType.LAZY) @JoinColumn(name="related_permission_id") private Permission relatedPermission;
    @Column(name="status") private String status="PENDING";
    @Column(name="created_at") private Instant createdAt=Instant.now();
    @Column(name="completed_at") private Instant completedAt;
}