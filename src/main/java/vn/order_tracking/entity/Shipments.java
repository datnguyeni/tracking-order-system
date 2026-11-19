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
import vn.order_tracking.entity.enums.ShipmentStatus;

import java.util.UUID;
import java.time.Instant;
import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "shipments")
public class Shipments extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", length = 36, nullable = false, updatable = false)
    private UUID id;

    @Column(name = "order_id")
    private UUID orderId;

    @Column(name = "carrier_id")
    private UUID carrierId;

    @Column(name = "tracking_number", length = 100, nullable = false)
    private String trackingNumber;

    @Column(name = "shipper_id")
    private UUID shipperId;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", length = 30, nullable = false)
    private ShipmentStatus status;

    @Column(name = "weight_grams")
    private BigDecimal weightGrams;

    @Column(name = "estimated_delivery_at")
    private Instant estimatedDeliveryAt;

    @Column(name = "picked_up_at")
    private Instant pickedUpAt;

    @Column(name = "delivered_at")
    private Instant deliveredAt;

    @Column(name = "returned_at")
    private Instant returnedAt;

    @Column(name = "cancelled_at")
    private Instant cancelledAt;

    @Column(name = "cancellation_reason", length = 1000)
    private String cancellationReason;

    @Column(name = "row_version", nullable = false)
    private Long rowVersion;

}
