package kr.or.koies.schoolzone.repository;

import kr.or.koies.schoolzone.entity.Notice;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NoticeRepository extends JpaRepository<Notice, Long> {}
