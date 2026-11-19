package vn.order_tracking.entity;


import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "user_roles")
public class UserRole extends  BaseEntity{

    @Id
    @GeneratedValue
    @Column(name = "id", length = 36, nullable = false, updatable = false)
    private UUID id;

    @Column(name = "user_id", length = 36, nullable = false)
    private UUID userId;

    @Column(name = "role_id", length = 36, nullable = false)
    private UUID roleId;

    @Column(name = "active_unique_marker", insertable = false, updatable = false)
    private Boolean activeUniqueMarker;

}
