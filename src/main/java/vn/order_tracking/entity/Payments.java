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
import vn.order_tracking.entity.enums.PaymentStatus;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "payments")
public class Payments extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "id", length = 36, nullable = false, updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "order_id", nullable = false)
    private Orders order;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "payment_type_id", nullable = false)
    private PaymentTypes paymentType;

    @Column(name = "payment_reference", length = 100, nullable = false)
    private String paymentReference;

    @Column(name = "provider_transaction_id", length = 150)
    private String providerTransactionId;

    @Column(name = "idempotency_key", length = 100, nullable = false)
    private String idempotencyKey;

    @Column(name = "amount", precision = 19, scale = 2, nullable = false)
    private BigDecimal amount;

    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "currency", length = 3, nullable = false)
    private String currency = "VND";

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "status", length = 30, nullable = false)
    private PaymentStatus status = PaymentStatus.PENDING;

    @JdbcTypeCode(SqlTypes.TIMESTAMP)
    @Column(name = "paid_at")
    private Instant paidAt;

    @JdbcTypeCode(SqlTypes.TIMESTAMP)
    @Column(name = "expires_at")
    private Instant expiresAt;

    @Column(name = "failure_reason", length = 1000)
    private String failureReason;


    }
