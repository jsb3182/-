package kr.or.koies.schoolzone.controller;

import kr.or.koies.schoolzone.common.ApiResponse;
import kr.or.koies.schoolzone.dto.StatusChangeRequest;
import kr.or.koies.schoolzone.entity.ZoneRequest;
import kr.or.koies.schoolzone.service.ZoneRequestService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/zone-requests")
public class ZoneRequestController {
    private final ZoneRequestService zoneRequestService;

    @GetMapping
    public ApiResponse<?> list(Pageable pageable) {
        return ApiResponse.ok(zoneRequestService.findAll(pageable));
    }

    @GetMapping("/{id}")
    public ApiResponse<?> detail(@PathVariable Long id) {
        return ApiResponse.ok(zoneRequestService.findById(id));
    }

    @PostMapping
    public ApiResponse<?> create(@RequestBody ZoneRequest request) {
        return ApiResponse.ok(zoneRequestService.save(request));
    }

    @PutMapping("/{id}")
    public ApiResponse<?> update(@PathVariable Long id, @RequestBody ZoneRequest request) {
        request.setRequestId(id);
        return ApiResponse.ok(zoneRequestService.save(request));
    }

    @PatchMapping("/{id}/status")
    public ApiResponse<?> changeStatus(@PathVariable Long id, @RequestBody StatusChangeRequest request) {
        return ApiResponse.ok(zoneRequestService.changeStatus(id, request));
    }
}
