package com.privacyos.entity;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import java.time.Instant;
import java.util.*;

@Entity @Table(name="users") @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class User implements UserDetails {
    @Id @GeneratedValue(strategy=GenerationType.UUID) private UUID id;
    @Column(unique=true,nullable=false) private String email;
    @Column(name="password_hash") private String passwordHash;
    @Column(name="full_name") private String fullName;
    @Column(name="avatar_url") private String avatarUrl;
    @Column(name="email_verified") private boolean emailVerified=false;
    @Column(name="privacy_score") private int privacyScore=50;
    @Column(name="risk_level") @Enumerated(EnumType.STRING) private RiskLevel riskLevel=RiskLevel.MEDIUM;
    @Column(name="provider") private String provider="LOCAL";
    @Column(name="provider_id") private String providerId;
    @Column(name="role") private String role="USER";
    @Column(name="created_at") private Instant createdAt=Instant.now();
    @Column(name="updated_at") private Instant updatedAt=Instant.now();
    @Column(name="deleted_at") private Instant deletedAt;
    @OneToMany(mappedBy="user",cascade=CascadeType.ALL,orphanRemoval=true,fetch=FetchType.LAZY)
    @Builder.Default private List<ConnectedAccount> connectedAccounts=new ArrayList<>();
    @OneToMany(mappedBy="user",cascade=CascadeType.ALL,orphanRemoval=true,fetch=FetchType.LAZY)
    @Builder.Default private List<BreachRecord> breachRecords=new ArrayList<>();
    @OneToMany(mappedBy="user",cascade=CascadeType.ALL,orphanRemoval=true,fetch=FetchType.LAZY)
    @Builder.Default private List<PrivacyRecommendation> recommendations=new ArrayList<>();
    @PreUpdate public void preUpdate(){this.updatedAt=Instant.now();}
    @Override public Collection<? extends GrantedAuthority> getAuthorities(){return List.of(new SimpleGrantedAuthority("ROLE_"+role));}
    @Override public String getPassword(){return passwordHash;}
    @Override public String getUsername(){return email;}
    @Override public boolean isAccountNonExpired(){return deletedAt==null;}
    @Override public boolean isAccountNonLocked(){return deletedAt==null;}
    @Override public boolean isCredentialsNonExpired(){return true;}
    @Override public boolean isEnabled(){return deletedAt==null;}
}