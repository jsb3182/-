package kr.or.koies.schoolzone.repository;

import kr.or.koies.schoolzone.entity.School;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SchoolRepository extends JpaRepository<School, Long> {}
