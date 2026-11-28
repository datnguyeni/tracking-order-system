package vn.order_tracking.controller;

import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import vn.order_tracking.dto.request.CreateUserRequest;
import vn.order_tracking.dto.response.BaseResponse;
import vn.order_tracking.dto.response.UserResponse;
import vn.order_tracking.service.UsersService;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UsersService usersService;

    @PostMapping
    public BaseResponse<UserResponse> createUser(@Valid @RequestBody CreateUserRequest request) {
        UserResponse user = usersService.createUser(request);
        return BaseResponse.ofCreated(user);
    }

    @GetMapping
    public BaseResponse<List<UserResponse>> getAllUsers() {
        return BaseResponse.ofSuccess(usersService.getAllUsers());
    }
}
