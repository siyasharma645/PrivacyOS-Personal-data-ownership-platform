package com.privacyos.entity;
import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.UUID;

@Entity @Table(name="refresh_tokens") @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class RefreshToken {
    @Id @GeneratedValue(strategy=GenerationType.UUID) private UUID id;
    @ManyToOne(fetch=FetchType.LAZY) @JoinColumn(name="user_id",nullable=false) private User user;
    @Column(unique=true,nullable=false,columnDefinition="TEXT") private String token;
    @Column(name="expires_at",nullable=false) private Instant expiresAt;
    @Column(name="revoked") private boolean revoked=false;
    @Column(name="created_at") private Instant createdAt=Instant.now();
}