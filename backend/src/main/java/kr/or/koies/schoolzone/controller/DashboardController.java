package kr.or.koies.schoolzone.controller;

import kr.or.koies.schoolzone.common.ApiResponse;
import kr.or.koies.schoolzone.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/dashboard")
public class DashboardController {
    private final DashboardService dashboardService;

    @GetMapping("/summary")
    public ApiResponse<?> summary() {
        return ApiResponse.ok(dashboardService.summary());
    }
}
