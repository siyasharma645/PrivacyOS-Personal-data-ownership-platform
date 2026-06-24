package com.privacyos.entity;
import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.UUID;

@Entity @Table(name="permissions") @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class Permission {
    @Id @GeneratedValue(strategy=GenerationType.UUID) private UUID id;
    @ManyToOne(fetch=FetchType.LAZY) @JoinColumn(name="account_id",nullable=false) private ConnectedAccount account;
    @Column(name="scope_name",nullable=false) private String scopeName;
    @Column(name="display_name") private String displayName;
    @Column(columnDefinition="TEXT") private String description;
    @Column(name="risk_level") @Enumerated(EnumType.STRING) private RiskLevel riskLevel=RiskLevel.LOW;
    @Column(name="category") private String category;
    @Column(name="data_types",columnDefinition="TEXT[]") @org.hibernate.annotations.Array(length=20) private String[] dataTypes;
    @Column(name="is_revocable") private boolean revocable=true;
    @Column(name="is_sensitive") private boolean sensitive=false;
    @Column(name="granted_at") private Instant grantedAt=Instant.now();
    @Column(name="revoked_at") private Instant revokedAt;
    @Column(name="created_at") private Instant createdAt=Instant.now();
}