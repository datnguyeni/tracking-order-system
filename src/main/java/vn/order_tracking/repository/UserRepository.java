package vn.order_tracking.repository;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import vn.order_tracking.entity.User;

public interface UserRepository extends JpaRepository<User, UUID> {
    boolean existsByEmailOrUsername(String email, String username);
    Optional<User> findByUsername(String username);


    Optional<User> findByEmail(String email);
}
