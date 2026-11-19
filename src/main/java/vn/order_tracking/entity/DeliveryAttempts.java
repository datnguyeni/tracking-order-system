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
import vn.order_tracking.entity.enums.DeliveryAttemptResult;

import java.util.UUID;
import java.time.Instant;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "delivery_attempts")
public class DeliveryAttempts extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", length = 36, nullable = false, updatable = false)
    private UUID id;

    @Column(name = "shipment_id")
    private UUID shipmentId;

    @Column(name = "attempt_number", nullable = false)
    private Integer attemptNumber;

    @Column(name = "shipper_id")
    private UUID shipperId;

    @Column(name = "attempted_at")
    private Instant attemptedAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "result", length = 20, nullable = false)
    private DeliveryAttemptResult result;

    @Column(name = "failure_reason", length = 1000)
    private String failureReason;

    @Column(name = "note", length = 2000)
    private String note;

    @Column(name = "next_attempt_at")
    private Instant nextAttemptAt;

}
