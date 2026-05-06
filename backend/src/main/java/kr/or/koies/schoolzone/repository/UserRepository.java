package kr.or.koies.schoolzone.repository;

import kr.or.koies.schoolzone.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByLoginId(String loginId);
}
