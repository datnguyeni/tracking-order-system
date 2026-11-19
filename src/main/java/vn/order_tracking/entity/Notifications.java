package vn.order_tracking.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import vn.order_tracking.entity.enums.NotificationStatus;

import java.util.UUID;
import java.time.Instant;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "notifications")
public class Notifications extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", length = 36, nullable = false, updatable = false)
    private UUID id;

    @Column(name = "order_id")
    private UUID orderId;

    @Column(name = "tracking_log_id")
    private UUID trackingLogId;

    @Column(name = "event_key", length = 200, nullable = false)
    private String eventKey;

    @Column(name = "channel", length = 10, nullable = false)
    private String channel;

    @Column(name = "recipient", length = 320, nullable = false)
    private String recipient;

    @Column(name = "subject", length = 255)
    private String subject;

    @Column(name = "content", nullable = false)
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", length = 20, nullable = false)
    private NotificationStatus status;

    @Column(name = "retry_count", nullable = false)
    private Integer retryCount;

    @Column(name = "max_attempts", nullable = false)
    private Integer maxAttempts;

    @Column(name = "next_retry_at")
    private Instant nextRetryAt;

    @Column(name = "locked_until")
    private Instant lockedUntil;

    @Column(name = "locked_by", length = 100)
    private String lockedBy;

    @Column(name = "sent_at")
    private Instant sentAt;

    @Column(name = "last_error", length = 2000)
    private String lastError;

}
