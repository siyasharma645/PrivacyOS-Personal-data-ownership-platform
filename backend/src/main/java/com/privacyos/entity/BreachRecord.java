package com.privacyos.entity;
import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity @Table(name="breach_records") @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class BreachRecord {
    @Id @GeneratedValue(strategy=GenerationType.UUID) private UUID id;
    @ManyToOne(fetch=FetchType.LAZY) @JoinColumn(name="user_id",nullable=false) private User user;
    @Column(name="breach_name",nullable=false) private String breachName;
    @Column(name="title") private String title;
    @Column(name="domain") private String domain;
    @Column(name="breach_date") private LocalDate breachDate;
    @Column(name="added_date") private LocalDate addedDate;
    @Column(name="data_classes",columnDefinition="TEXT[]") @org.hibernate.annotations.Array(length=30) private String[] dataClasses;
    @Column(name="pwn_count") private Long pwnCount;
    @Column(name="description",columnDefinition="TEXT") private String description;
    @Column(name="logo_path") private String logoPath;
    @Column(name="is_verified") private boolean verified=true;
    @Column(name="is_sensitive") private boolean sensitive=false;
    @Column(name="is_fabricated") private boolean fabricated=false;
    @Column(name="is_retired") private boolean retired=false;
    @Column(name="is_spam_list") private boolean spamList=false;
    @Column(name="remediated_at") private Instant remediatedAt;
    @Column(name="created_at") private Instant createdAt=Instant.now();
}