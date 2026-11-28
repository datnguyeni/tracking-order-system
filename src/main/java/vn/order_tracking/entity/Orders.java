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
import vn.order_tracking.entity.enums.OrderPaymentStatus;
import vn.order_tracking.entity.enums.OrderStatus;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "orders")
public class Orders extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "id", length = 36, nullable = false, updatable = false)
    private UUID id;

    @Column(name = "order_number", length = 50, nullable = false)
    private String orderNumber;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "buyer_id", nullable = false)
    private User buyer;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "seller_id", nullable = false)
    private User seller;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "status", length = 30, nullable = false)
    private OrderStatus status = OrderStatus.PENDING;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "payment_status", length = 30, nullable = false)
    private OrderPaymentStatus paymentStatus = OrderPaymentStatus.UNPAID;

    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "currency", length = 3, nullable = false)
    private String currency = "VND";

    @Column(name = "subtotal", precision = 19, scale = 2, nullable = false)
    private BigDecimal subtotal;

    @Column(name = "discount_total", precision = 19, scale = 2, nullable = false)
    private BigDecimal discountTotal = BigDecimal.ZERO;

    @Column(name = "shipping_fee", precision = 19, scale = 2, nullable = false)
    private BigDecimal shippingFee = BigDecimal.ZERO;

    @Column(name = "grand_total", precision = 19, scale = 2, nullable = false)
    private BigDecimal grandTotal;

    @Column(name = "customer_note", length = 1000)
    private String customerNote;

    @Column(name = "recipient_name", length = 150, nullable = false)
    private String recipientName;

    @Column(name = "recipient_phone", length = 30, nullable = false)
    private String recipientPhone;

    @Column(name = "shipping_address_line", length = 500, nullable = false)
    private String shippingAddressLine;

    @Column(name = "shipping_ward", length = 150)
    private String shippingWard;

    @Column(name = "shipping_district", length = 150)
    private String shippingDistrict;

    @Column(name = "shipping_province", length = 150, nullable = false)
    private String shippingProvince;

    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "shipping_country_code", length = 2, nullable = false)
    private String shippingCountryCode = "VN";

    @Column(name = "shipping_postal_code", length = 20)
    private String shippingPostalCode;

    @JdbcTypeCode(SqlTypes.TIMESTAMP)
    @Column(name = "placed_at", nullable = false)
    private Instant placedAt;

    @JdbcTypeCode(SqlTypes.TIMESTAMP)
    @Column(name = "confirmed_at")
    private Instant confirmedAt;

    @JdbcTypeCode(SqlTypes.TIMESTAMP)
    @Column(name = "cancelled_at")
    private Instant cancelledAt;

    @Column(name = "cancellation_reason", length = 1000)
    private String cancellationReason;

    @JdbcTypeCode(SqlTypes.TIMESTAMP)
    @Column(name = "payment_due_at")
    private Instant paymentDueAt;


    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
    private List<OrderItems> orderItems = new ArrayList<>();

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
    private List<OrderDiscounts> orderDiscounts = new ArrayList<>();

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
    private List<Payments> payments = new ArrayList<>();

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
    private List<Shipments> shipments = new ArrayList<>();














}
