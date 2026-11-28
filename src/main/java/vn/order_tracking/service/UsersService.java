package vn.order_tracking.service;

import java.util.List;
import vn.order_tracking.dto.request.CreateUserRequest;
import vn.order_tracking.dto.response.UserResponse;

public interface UsersService {

    UserResponse createUser(CreateUserRequest request);

    List<UserResponse> getAllUsers();
}
