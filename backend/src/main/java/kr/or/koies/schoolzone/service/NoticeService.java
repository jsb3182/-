package kr.or.koies.schoolzone.service;

import kr.or.koies.schoolzone.entity.Notice;
import kr.or.koies.schoolzone.repository.NoticeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class NoticeService {
    private final NoticeRepository noticeRepository;

    public Page<Notice> findAll(Pageable pageable) { return noticeRepository.findAll(pageable); }

    public Notice findById(Long id) {
        return noticeRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("공지사항을 찾을 수 없습니다."));
    }

    public Notice save(Notice notice) { return noticeRepository.save(notice); }

    @Transactional
    public Notice increaseViewCount(Long id) {
        Notice notice = findById(id);
        notice.setViewCount(notice.getViewCount() == null ? 1 : notice.getViewCount() + 1);
        return notice;
    }
}
