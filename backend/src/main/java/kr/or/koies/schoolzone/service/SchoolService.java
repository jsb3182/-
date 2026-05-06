package kr.or.koies.schoolzone.service;

import kr.or.koies.schoolzone.entity.School;
import kr.or.koies.schoolzone.repository.SchoolNativeRepository;
import kr.or.koies.schoolzone.repository.SchoolRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class SchoolService {
    private final SchoolRepository schoolRepository;
    private final SchoolNativeRepository schoolNativeRepository;

    public Page<School> findAll(Pageable pageable) {
        return schoolRepository.findAll(pageable);
    }

    public School findById(Long id) {
        return schoolRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("학교 정보를 찾을 수 없습니다."));
    }

    @Transactional
    public School save(School school) {
        School saved = schoolRepository.save(school);
        if (saved.getXCoord() != null && saved.getYCoord() != null) {
            schoolNativeRepository.updateGeomBySchoolId(saved.getSchoolId(), saved.getXCoord(), saved.getYCoord());
        }
        return saved;
    }
}
