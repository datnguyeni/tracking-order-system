package vn.order_tracking.entity;

import jakarta.persistence.*;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "user_addresses")
public class UserAddress extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "id", length = 36, nullable = false, updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "label", length = 50)
    private String label;

    @Column(name = "recipient_name", length = 150, nullable = false)
    private String recipientName;

    @Column(name = "recipient_phone", length = 30, nullable = false)
    private String recipientPhone;

    @Column(name = "address_line", length = 500, nullable = false)
    private String addressLine;

    @Column(name = "ward", length = 150)
    private String ward;

    @Column(name = "district", length = 150)
    private String district;

    @Column(name = "province", length = 150, nullable = false)
    private String province;

    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "country_code", length = 2, nullable = false)
    private String countryCode = "VN";

    @Column(name = "postal_code", length = 20)
    private String postalCode;

    @Column(name = "is_default", nullable = false)
    private boolean isDefault = false;

    @Setter(lombok.AccessLevel.NONE)
    @JdbcTypeCode(SqlTypes.TINYINT)
    @Column(name = "default_unique_marker", insertable = false, updatable = false)
    private Boolean defaultUniqueMarker;

    }
