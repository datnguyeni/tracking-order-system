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
import vn.order_tracking.entity.enums.OrderPaymentStatus;
import vn.order_tracking.entity.enums.OrderStatus;

import java.util.UUID;
import java.time.Instant;
import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "orders")
public class Orders extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", length = 36, nullable = false, updatable = false)
    private UUID id;

    @Column(name = "order_number", length = 50, nullable = false)
    private String orderNumber;

    @Column(name = "buyer_id")
    private UUID buyerId;

    @Column(name = "seller_id")
    private UUID sellerId;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", length = 30, nullable = false)
    private OrderStatus status;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_status", length = 30, nullable = false)
    private OrderPaymentStatus paymentStatus;

    @Column(name = "currency", length = 3, nullable = false)
    private String currency;

    @Column(name = "subtotal")
    private BigDecimal subtotal;

    @Column(name = "discount_total")
    private BigDecimal discountTotal;

    @Column(name = "shipping_fee")
    private BigDecimal shippingFee;

    @Column(name = "grand_total")
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

    @Column(name = "shipping_country_code", length = 2, nullable = false)
    private String shippingCountryCode;

    @Column(name = "shipping_postal_code", length = 20)
    private String shippingPostalCode;

    @Column(name = "placed_at")
    private Instant placedAt;

    @Column(name = "confirmed_at")
    private Instant confirmedAt;

    @Column(name = "cancelled_at")
    private Instant cancelledAt;

    @Column(name = "cancellation_reason", length = 1000)
    private String cancellationReason;

    @Column(name = "payment_due_at")
    private Instant paymentDueAt;

    @Column(name = "row_version", nullable = false)
    private Long rowVersion;

}
