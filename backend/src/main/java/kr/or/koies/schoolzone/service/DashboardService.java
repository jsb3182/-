package kr.or.koies.schoolzone.service;

import kr.or.koies.schoolzone.repository.NoticeRepository;
import kr.or.koies.schoolzone.repository.SchoolRepository;
import kr.or.koies.schoolzone.repository.ZoneRequestRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class DashboardService {
    private final ZoneRequestRepository zoneRequestRepository;
    private final SchoolRepository schoolRepository;
    private final NoticeRepository noticeRepository;

    public Map<String, Object> summary() {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("zoneRequestCount", zoneRequestRepository.count());
        map.put("schoolCount", schoolRepository.count());
        map.put("noticeCount", noticeRepository.count());
        return map;
    }
}
