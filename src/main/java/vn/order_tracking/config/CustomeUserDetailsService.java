package vn.order_tracking.config;


import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.order_tracking.entity.User;
import vn.order_tracking.entity.enums.UserStatus;
import vn.order_tracking.repository.UserRepository;

@RequiredArgsConstructor
@Service
public class CustomeUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String email)
            throws UsernameNotFoundException {

        User user = userRepository.findByEmail(email)
                .orElseThrow(() ->
                        new UsernameNotFoundException("User not found by email"));

        if (user.isDeleted()
                || user.getStatus() != UserStatus.ACTIVE) {
            throw new UsernameNotFoundException("User is not active");
        }

        var authorities = user.getUserRoles().stream()
                .filter(userRole -> !userRole.isDeleted())
                .map(userRole -> new SimpleGrantedAuthority(
                        "ROLE_" + userRole.getRole().getCode()
                ))
                .toList();


        return org.springframework.security.core.userdetails.User
                .withUsername(user.getEmail())
                .password(user.getPasswordHash())
                .authorities(authorities)
                .build();
    }


}
