package com.privacyos.entity;
import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.*;

@Entity @Table(name="connected_accounts") @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class ConnectedAccount {
    @Id @GeneratedValue(strategy=GenerationType.UUID) private UUID id;
    @ManyToOne(fetch=FetchType.LAZY) @JoinColumn(name="user_id",nullable=false) private User user;
    @Column(nullable=false) private String provider;
    @Column(name="provider_user_id",nullable=false) private String providerUserId;
    @Column(name="provider_email") private String providerEmail;
    @Column(name="display_name") private String displayName;
    @Column(name="avatar_url") private String avatarUrl;
    @Column(name="access_token",columnDefinition="TEXT") private String accessToken;
    @Column(name="refresh_token",columnDefinition="TEXT") private String refreshToken;
    @Column(name="token_expires_at") private Instant tokenExpiresAt;
    @Column(name="scopes",columnDefinition="TEXT[]") @org.hibernate.annotations.Array(length=50) private String[] scopes;
    @Column(name="risk_contribution") private int riskContribution=0;
    @Column(name="status") private String status="ACTIVE";
    @Column(name="last_synced_at") private Instant lastSyncedAt;
    @Column(name="created_at") private Instant createdAt=Instant.now();
    @Column(name="updated_at") private Instant updatedAt=Instant.now();
    @OneToMany(mappedBy="account",cascade=CascadeType.ALL,orphanRemoval=true,fetch=FetchType.EAGER)
    @Builder.Default private List<Permission> permissions=new ArrayList<>();
    @PreUpdate public void preUpdate(){this.updatedAt=Instant.now();}
}