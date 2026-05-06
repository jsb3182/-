package kr.or.koies.schoolzone;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * GIS 학구도 자동 관리시스템 1차 MVP 실행 클래스입니다.
 *
 * 전자정부프레임워크 구조를 적용할 경우에도 Spring Boot 진입점은 유지하고,
 * 공통 컴포넌트/공통 예외/공통 응답 구조를 별도 패키지로 확장하면 됩니다.
 */
@SpringBootApplication
public class SchoolzoneApplication {
    public static void main(String[] args) {
        SpringApplication.run(SchoolzoneApplication.class, args);
    }
}
