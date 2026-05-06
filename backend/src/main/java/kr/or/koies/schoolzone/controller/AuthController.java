package kr.or.koies.schoolzone.controller;

import kr.or.koies.schoolzone.common.ApiResponse;
import kr.or.koies.schoolzone.dto.LoginRequest;
import kr.or.koies.schoolzone.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/auth")
public class AuthController {
    private final AuthService authService;

    @PostMapping("/login")
    public ApiResponse<?> login(@RequestBody LoginRequest request) {
        return ApiResponse.ok(authService.login(request));
    }
}
