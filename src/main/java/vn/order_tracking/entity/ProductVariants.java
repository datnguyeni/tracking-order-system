package vn.order_tracking.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;
import java.time.Instant;
import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "product_variants")
public class ProductVariants extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", length = 36, nullable = false, updatable = false)
    private UUID id;

    @Column(name = "product_id")
    private UUID productId;

    @Column(name = "sku", length = 100, nullable = false)
    private String sku;

    @Column(name = "name", length = 255)
    private String name;

    @Column(name = "color", length = 100)
    private String color;

    @Column(name = "size", length = 100)
    private String size;

    @Column(name = "price")
    private BigDecimal price;

    @Column(name = "weight_grams")
    private BigDecimal weightGrams;

    @Column(name = "is_active")
    private boolean isActive;

}
