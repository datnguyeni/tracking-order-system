package vn.order_tracking.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import vn.order_tracking.entity.enums.ShipmentStatus;
import vn.order_tracking.entity.enums.TrackingSource;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "tracking_logs")
public class TrackingLogs extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "id", length = 36, nullable = false, updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "shipment_id", nullable = false)
    private Shipments shipment;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "actor_id")
    private User actor;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "from_status", length = 30)
    private ShipmentStatus fromStatus;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "to_status", length = 30, nullable = false)
    private ShipmentStatus toStatus;

    @JdbcTypeCode(SqlTypes.TIMESTAMP)
    @Column(name = "event_time", nullable = false)
    private Instant eventTime;

    @Column(name = "location", length = 500)
    private String location;

    @Column(name = "latitude", precision = 9, scale = 6)
    private BigDecimal latitude;

    @Column(name = "longitude", precision = 9, scale = 6)
    private BigDecimal longitude;

    @Column(name = "note", length = 2000)
    private String note;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "source", length = 20, nullable = false)
    private TrackingSource source;

    @Column(name = "external_event_id", length = 150)
    private String externalEventId;

    
    @PrePersist
    protected void initializeEventTime() {
        if (eventTime == null) {
            eventTime = Instant.now();
        }
    }
}
