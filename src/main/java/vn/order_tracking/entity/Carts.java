package vn.order_tracking.entity;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import vn.order_tracking.entity.enums.CartStatus;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "carts")
public class Carts extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "id", length = 36, nullable = false, updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "status", length = 20, nullable = false)
    private CartStatus status = CartStatus.ACTIVE;

    @Setter(lombok.AccessLevel.NONE)
    @JdbcTypeCode(SqlTypes.TINYINT)
    @Column(name = "active_unique_marker", insertable = false, updatable = false)
    private Boolean activeUniqueMarker;

    @OneToMany(mappedBy = "cart", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<CartItems> cartItems = new ArrayList<>();





}
