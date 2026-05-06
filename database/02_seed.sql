-- 초기 관리자 계정
-- 비밀번호 예시: admin1234! 를 BCrypt로 암호화한 값으로 교체해서 사용하세요.
INSERT INTO tb_user (login_id, password, user_name, role, department_name, email, phone_number)
VALUES ('admin', '$2a$10$replace_with_real_bcrypt_hash', '관리자', 'ADMIN', '학구도관리팀', 'admin@example.go.kr', '02-0000-0000')
ON CONFLICT (login_id) DO NOTHING;

INSERT INTO tb_notice (title, content, writer_name, notice_type, fixed_yn)
VALUES ('GIS 학구도 자동 관리시스템 오픈 안내', '1차 MVP 시스템 초기 공지사항입니다.', '관리자', '시스템', 'Y');
