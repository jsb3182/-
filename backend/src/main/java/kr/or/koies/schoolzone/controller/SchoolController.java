package kr.or.koies.schoolzone.controller;

import kr.or.koies.schoolzone.common.ApiResponse;
import kr.or.koies.schoolzone.entity.School;
import kr.or.koies.schoolzone.service.SchoolService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/schools")
public class SchoolController {
    private final SchoolService schoolService;

    @GetMapping
    public ApiResponse<?> list(Pageable pageable) { return ApiResponse.ok(schoolService.findAll(pageable)); }

    @GetMapping("/{id}")
    public ApiResponse<?> detail(@PathVariable Long id) { return ApiResponse.ok(schoolService.findById(id)); }

    @PostMapping
    public ApiResponse<?> create(@RequestBody School school) { return ApiResponse.ok(schoolService.save(school)); }

    @PutMapping("/{id}")
    public ApiResponse<?> update(@PathVariable Long id, @RequestBody School school) {
        school.setSchoolId(id);
        return ApiResponse.ok(schoolService.save(school));
    }
}
