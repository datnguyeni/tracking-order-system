package vn.order_tracking.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import vn.order_tracking.entity.enums.ShipmentStatus;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "shipments")
public class Shipments extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "id", length = 36, nullable = false, updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "order_id", nullable = false)
    private Orders order;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "carrier_id", nullable = false)
    private Carriers carrier;

    @Column(name = "tracking_number", length = 100, nullable = false)
    private String trackingNumber;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shipper_id")
    private User shipper;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "status", length = 30, nullable = false)
    private ShipmentStatus status = ShipmentStatus.PENDING;

    @Column(name = "weight_grams", precision = 12, scale = 3, nullable = false)
    private BigDecimal weightGrams;

    @JdbcTypeCode(SqlTypes.TIMESTAMP)
    @Column(name = "estimated_delivery_at")
    private Instant estimatedDeliveryAt;

    @JdbcTypeCode(SqlTypes.TIMESTAMP)
    @Column(name = "picked_up_at")
    private Instant pickedUpAt;

    @JdbcTypeCode(SqlTypes.TIMESTAMP)
    @Column(name = "delivered_at")
    private Instant deliveredAt;

    @JdbcTypeCode(SqlTypes.TIMESTAMP)
    @Column(name = "returned_at")
    private Instant returnedAt;

    @JdbcTypeCode(SqlTypes.TIMESTAMP)
    @Column(name = "cancelled_at")
    private Instant cancelledAt;

    @Column(name = "cancellation_reason", length = 1000)
    private String cancellationReason;


    @OneToMany(mappedBy = "shipment", cascade = CascadeType.ALL)
    private List<TrackingLogs> trackingLogs = new ArrayList<>();

    @OneToMany(mappedBy = "shipment", cascade = CascadeType.ALL)
    private List<DeliveryAttempts> deliveryAttempts = new ArrayList<>();

    






}
