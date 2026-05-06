package kr.or.koies.schoolzone.controller;

import kr.or.koies.schoolzone.common.ApiResponse;
import kr.or.koies.schoolzone.entity.Notice;
import kr.or.koies.schoolzone.service.NoticeService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/notices")
public class NoticeController {
    private final NoticeService noticeService;

    @GetMapping
    public ApiResponse<?> list(Pageable pageable) { return ApiResponse.ok(noticeService.findAll(pageable)); }

    @GetMapping("/{id}")
    public ApiResponse<?> detail(@PathVariable Long id) { return ApiResponse.ok(noticeService.findById(id)); }

    @PostMapping
    public ApiResponse<?> create(@RequestBody Notice notice) { return ApiResponse.ok(noticeService.save(notice)); }

    @PatchMapping("/{id}/view-count")
    public ApiResponse<?> viewCount(@PathVariable Long id) { return ApiResponse.ok(noticeService.increaseViewCount(id)); }
}
