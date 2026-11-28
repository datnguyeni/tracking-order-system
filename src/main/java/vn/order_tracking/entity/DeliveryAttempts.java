package vn.order_tracking.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import vn.order_tracking.entity.enums.DeliveryAttemptResult;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "delivery_attempts")
public class DeliveryAttempts extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "id", length = 36, nullable = false, updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "shipment_id", nullable = false)
    private Shipments shipment;

    @Column(name = "attempt_number", nullable = false)
    private Integer attemptNumber;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "shipper_id", nullable = false)
    private User shipper;

    @JdbcTypeCode(SqlTypes.TIMESTAMP)
    @Column(name = "attempted_at", nullable = false)
    private Instant attemptedAt;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "result", length = 20, nullable = false)
    private DeliveryAttemptResult result;

    @Column(name = "failure_reason", length = 1000)
    private String failureReason;

    @Column(name = "note", length = 2000)
    private String note;

    @JdbcTypeCode(SqlTypes.TIMESTAMP)
    @Column(name = "next_attempt_at")
    private Instant nextAttemptAt;

    }
