package com.privacyos.entity;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Entity @Table(name="privacy_events") @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class PrivacyEvent {
    @Id @GeneratedValue(strategy=GenerationType.UUID) private UUID id;
    @ManyToOne(fetch=FetchType.LAZY) @JoinColumn(name="user_id",nullable=false) private User user;
    @Column(name="event_type",nullable=false) private String eventType;
    @Column(name="entity_id") private UUID entityId;
    @Column(name="entity_type") private String entityType;
    @Column(name="title") private String title;
    @Column(name="description",columnDefinition="TEXT") private String description;
    @JdbcTypeCode(SqlTypes.JSON) @Column(name="payload",columnDefinition="jsonb") private Map<String,Object> payload;
    @Column(name="severity") @Enumerated(EnumType.STRING) private EventSeverity severity=EventSeverity.INFO;
    @Column(name="score_before") private Integer scoreBefore;
    @Column(name="score_after") private Integer scoreAfter;
    @Column(name="created_at") private Instant createdAt=Instant.now();
}