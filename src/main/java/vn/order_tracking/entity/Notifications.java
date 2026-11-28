package vn.order_tracking.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import vn.order_tracking.entity.enums.NotificationChannel;
import vn.order_tracking.entity.enums.NotificationStatus;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "notifications")
public class Notifications extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "id", length = 36, nullable = false, updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "order_id", nullable = false)
    private Orders order;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tracking_log_id")
    private TrackingLogs trackingLog;

    @Column(name = "event_key", length = 200, nullable = false)
    private String eventKey;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "channel", length = 10, nullable = false)
    private NotificationChannel channel;

    @Column(name = "recipient", length = 320, nullable = false)
    private String recipient;

    @Column(name = "subject", length = 255)
    private String subject;

    @Column(name = "content", columnDefinition = "LONGTEXT", nullable = false)
    private String content;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "status", length = 20, nullable = false)
    private NotificationStatus status = NotificationStatus.PENDING;

    @Column(name = "retry_count", nullable = false)
    private Integer retryCount = 0;

    @Column(name = "max_attempts", nullable = false)
    private Integer maxAttempts = 5;

    @JdbcTypeCode(SqlTypes.TIMESTAMP)
    @Column(name = "next_retry_at", nullable = false)
    private Instant nextRetryAt;

    @JdbcTypeCode(SqlTypes.TIMESTAMP)
    @Column(name = "locked_until")
    private Instant lockedUntil;

    @Column(name = "locked_by", length = 100)
    private String lockedBy;

    @JdbcTypeCode(SqlTypes.TIMESTAMP)
    @Column(name = "sent_at")
    private Instant sentAt;

    @Column(name = "last_error", length = 2000)
    private String lastError;

    @PrePersist
    protected void initializeNextRetryAt() {
        if (nextRetryAt == null) {
            nextRetryAt = Instant.now();
        }
    }
}
