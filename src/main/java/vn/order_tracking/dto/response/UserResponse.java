package vn.order_tracking.dto.response;

import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Getter;
import vn.order_tracking.entity.User;
import vn.order_tracking.entity.enums.UserStatus;

@Getter
@AllArgsConstructor
public class UserResponse {
    private UUID id;
    private String email;
    private String username;
    private String fullName;
    private String phone;
    private UserStatus status;

    public static UserResponse from(User user) {
        return new UserResponse(
                user.getId(),
                user.getEmail(),
                user.getUsername(),
                user.getFullName(),
                user.getPhone(),
                user.getStatus());
    }
}
