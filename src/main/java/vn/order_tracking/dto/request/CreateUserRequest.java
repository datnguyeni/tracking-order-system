package vn.order_tracking.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class CreateUserRequest {
    @NotBlank
    @Email
    @Size(max = 100)
    private String email;

    @NotBlank
    @Size(max = 100)
    private String username;

    @NotBlank
    @Size(min = 4, max = 10)
    private String password;

    @NotBlank
    @Size(max = 150)
    private String fullName;

    @Size(max = 20)
    private String phone;
}
