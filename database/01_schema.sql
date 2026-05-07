-- ==============================================================================
-- 프로젝트: GIS 학구도 자동 관리시스템 1차 MVP DB 스키마
-- 좌표계: EPSG:5186 (한국 표준 국가기본도 좌표계 통일)
-- ==============================================================================

-- 1. 공간 데이터 처리를 위한 PostGIS 확장 모듈 활성화
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. 데이터 수정 시 'updated_at(수정일)' 컬럼을 현재 시간으로 자동 갱신하는 공통 
CREATE OR REPLACE FUNCTION fn_update_timestamp()
RETUENS TRIGGER AS $$
BEGIN
    NEW.updated_at = current_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpqsql;    

-- ==============================================================================
-- [테이블] 1. 사용자 정보 관리 (tb_user)
-- 시스템에 로그인하고 시스템을 사용하는 관리자 및 작업자 정보
-- ==============================================================================
CREATE TABLE IF NOT EXISTS tb_user (
    user_id BIGSERIAL PRIMARY KEY,                     -- 사용자 고유 PK (자동 증가)
    login_id VARCHAR(50) NOT NULL UNIQUE,              -- 로그인 아이디 (중복 불가)
    password VARCHAR(255) NOT NULL,                    -- 암호화된 비밀번호
    user_name VARCHAR(100) NOT NULL,                   -- 사용자 실제 이름
    role VARCHAR(30) NOT NULL CHECK (role IN ('ADMIN','MANAGER','WORKER','VIEWER')), -- 권한 (최고관리자, 중간관리자, 실무작업자, 조회자)
    department_name VARCHAR(100),                      -- 소속 부서명
    email VARCHAR(100),                                -- 이메일 주소
    phone_number VARCHAR(50),                          -- 연락처
    use_yn CHAR(1) DEFAULT 'Y' CHECK (use_yn IN ('Y','N')), -- 계정 사용(활성화) 여부
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- 계정 생성일시
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP     -- 계정 정보 수정일시
);

-- ==============================================================================
-- [테이블] 2. 학교 기본 정보 (tb_school)
-- 학구도 관리의 기준이 되는 학교들의 속성 및 공간(Geometry) 데이터
-- ==============================================================================
CREATE TABLE IF NOT EXISTS tb_school (
    school_id BIGSERIAL PRIMARY KEY,                   -- 학교 고유 PK
    school_code VARCHAR(50),                           -- 표준 학교 코드
    school_name VARCHAR(200) NOT NULL,                 -- 학교명
    school_level VARCHAR(50),                          -- 학교 급 (초등학교, 중학교, 고등학교 등)
    establish_type VARCHAR(50),                        -- 설립 유형 (공립, 사립, 국립)
    operation_status VARCHAR(50),                      -- 운영 상태 (운영, 폐교, 휴교 등)
    education_office VARCHAR(100),                     -- 관할 시도 교육청
    support_office VARCHAR(100),                       -- 관할 교육지원청
    road_address TEXT,                                 -- 도로명 주소
    jibun_address TEXT,                                -- 지번 주소
    x_coord NUMERIC(15,3),                             -- X 좌표 (경도 또는 평면직각좌표)
    y_coord NUMERIC(15,3),                             -- Y 좌표 (위도 또는 평면직각좌표)
    geom geometry(Point, 5186),                        -- 공간 데이터: 점(Point) 타입, EPSG:5186 적용
    use_yn CHAR(1) DEFAULT 'Y' CHECK (use_yn IN ('Y','N')), -- 데이터 사용 여부
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- 등록일시
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP     -- 수정일시
);

-- 공간 검색 및 필터링 속도 향상을 위한 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_tb_school_geom ON tb_school USING GIST (geom); -- 공간 데이터 특화 인덱스 (GIST)
CREATE INDEX IF NOT EXISTS idx_tb_school_name ON tb_school (school_name);     -- 학교명 검색 인덱스
CREATE INDEX IF NOT EXISTS idx_tb_school_office ON tb_school (education_office, support_office); -- 교육청 필터링 인덱스

-- ==============================================================================
-- [테이블] 3. 학구도 변경/작업 요청 관리 (tb_school_zone_request)
-- 학구도 형상 변경, 신설, 수정 등에 대한 작업 요청 접수 및 진행 상태 관리
-- ==============================================================================
CREATE TABLE IF NOT EXISTS tb_school_zone_request (
    request_id BIGSERIAL PRIMARY KEY,                  -- 요청 고유 PK
    request_no VARCHAR(50),                            -- 문서/요청 번호 (관리용)
    apply_no VARCHAR(50),                              -- 접수 번호
    register_type VARCHAR(50),                         -- 등록 유형 (신규, 변경, 삭제 등)
    register_detail VARCHAR(100),                      -- 등록 상세 내용
    zone_name VARCHAR(200),                            -- 대상 학구도 명칭
    announced_zone_name VARCHAR(200),                  -- 고시된 학구도 명칭 (공식 명칭)
    education_office VARCHAR(100),                     -- 관련 시도 교육청
    support_office VARCHAR(100),                       -- 관련 교육지원청
    school_level VARCHAR(50),                          -- 대상 학교 급 (초, 중, 고)
    zone_type VARCHAR(100),                            -- 학구도 유형 (통학구, 중학구 등)
    register_date DATE,                                -- 요청 등록 일자 (연/월/일)
    effective_month VARCHAR(20),                       -- 적용/시행 년월
    progress_status VARCHAR(30) DEFAULT '등록' CHECK (progress_status IN ('등록','접수','작업','검토','적용','완료','취소','재요청')), -- 현재 작업 진행 상태
    worker_id BIGINT,                                  -- 담당 작업자 ID (tb_user 참조 용도)
    worker_name VARCHAR(100),                          -- 담당 작업자 이름
    department_name VARCHAR(100),                      -- 담당 부서
    manager_name VARCHAR(100),                         -- 담당 관리자 이름
    phone_number VARCHAR(50),                          -- 연락처
    email VARCHAR(100),                                -- 이메일
    request_content TEXT,                              -- 요청 상세 내용
    source_url TEXT,                                   -- 참고/출처 URL (고시문 링크 등)
    work_memo TEXT,                                    -- 작업자 메모
    review_memo TEXT,                                  -- 검토자 메모
    use_yn CHAR(1) DEFAULT 'Y' CHECK (use_yn IN ('Y','N')), -- 데이터 유효 여부
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- 생성일시
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP     -- 수정일시
);

-- 진행 상태 및 주요 검색 조건에 대한 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_zone_request_status ON tb_school_zone_request(progress_status);
CREATE INDEX IF NOT EXISTS idx_zone_request_zone_name ON tb_school_zone_request(zone_name);
CREATE INDEX IF NOT EXISTS idx_zone_request_office ON tb_school_zone_request(education_office, support_office);
CREATE INDEX IF NOT EXISTS idx_zone_request_register_date ON tb_school_zone_request(register_date);

-- ==============================================================================
-- [테이블] 4. 요청 진행 상태 변경 이력 (tb_request_status_history)
-- 학구도 요청건의 상태(접수->작업->검토->완료)가 언제, 누구에 의해 변경되었는지 추적
-- ==============================================================================
CREATE TABLE IF NOT EXISTS tb_request_status_history (
    history_id BIGSERIAL PRIMARY KEY,                  -- 이력 고유 PK
    request_id BIGINT NOT NULL REFERENCES tb_school_zone_request(request_id), -- 연관된 요청 ID (외래키)
    before_status VARCHAR(30),                         -- 변경 전 상태
    after_status VARCHAR(30),                          -- 변경 후 상태
    changed_by BIGINT,                                 -- 상태를 변경한 사용자 ID
    changed_by_name VARCHAR(100),                      -- 상태를 변경한 사용자 이름
    change_reason TEXT,                                -- 변경/반려 사유 등
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP     -- 변경 발생 일시
);

CREATE INDEX IF NOT EXISTS idx_status_history_request ON tb_request_status_history(request_id);

-- ==============================================================================
-- [테이블] 5. 공지사항 및 게시판 (tb_notice)
-- 시스템 사용자들을 위한 공지사항 공유
-- ==============================================================================
CREATE TABLE IF NOT EXISTS tb_notice (
    notice_id BIGSERIAL PRIMARY KEY,                   -- 공지사항 고유 PK
    title VARCHAR(300) NOT NULL,                       -- 공지 제목
    content TEXT NOT NULL,                             -- 공지 내용 (HTML 텍스트 등)
    writer_id BIGINT,                                  -- 작성자 ID
    writer_name VARCHAR(100),                          -- 작성자 이름
    notice_type VARCHAR(50),                           -- 공지 유형 (일반, 긴급, 업데이트 등)
    fixed_yn CHAR(1) DEFAULT 'N' CHECK (fixed_yn IN ('Y','N')), -- 상단 고정 여부
    view_count INTEGER DEFAULT 0,                      -- 조회수
    use_yn CHAR(1) DEFAULT 'Y' CHECK (use_yn IN ('Y','N')), -- 게시글 표시 여부 (N이면 삭제 처리)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- 작성일시
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP     -- 수정일시
);

-- 상단 고정글을 먼저 보여주기 위한 정렬용 인덱스
CREATE INDEX IF NOT EXISTS idx_notice_fixed ON tb_notice(fixed_yn, created_at DESC);

-- ==============================================================================
-- [테이블] 6. 통합 첨부파일 관리 (tb_attachment_file)
-- 공지사항, 요청건 등 여러 테이블에서 발생하는 첨부파일을 한 곳에서 관리 (다형성 구조)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS tb_attachment_file (
    file_id BIGSERIAL PRIMARY KEY,                     -- 파일 고유 PK
    target_type VARCHAR(50),                           -- 파일이 첨부된 출처 테이블 (예: 'NOTICE', 'ZONE_REQUEST')
    target_id BIGINT,                                  -- 출처 테이블의 해당 레코드 PK (notice_id, request_id 등)
    original_file_name VARCHAR(255),                   -- 사용자가 업로드한 원본 파일명
    stored_file_name VARCHAR(255),                     -- 서버/스토리지에 실제 저장된 난수화된 파일명
    file_path TEXT,                                    -- 파일이 저장된 서버 경로 또는 URL
    file_size BIGINT,                                  -- 파일 용량 (바이트 단위)
    file_ext VARCHAR(20),                              -- 파일 확장자 (jpg, pdf, zip 등)
    uploaded_by BIGINT,                                -- 업로드한 사용자 ID
    uploaded_by_name VARCHAR(100),                     -- 업로드한 사용자 이름
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP    -- 업로드 일시
);

-- 어떤 게시글/요청건의 첨부파일인지 빠르게 찾기 위한 인덱스
CREATE INDEX IF NOT EXISTS idx_attachment_target ON tb_attachment_file(target_type, target_id);

-- ==============================================================================
-- [테이블] 7. 엑셀 일괄 업로드 이력 관리 (tb_excel_upload_history)
-- 학교 정보나 학구도 정보를 엑셀로 대량 업로드했을 때의 성공/실패 내역 로깅
-- ==============================================================================
CREATE TABLE IF NOT EXISTS tb_excel_upload_history (
    upload_id BIGSERIAL PRIMARY KEY,                   -- 업로드 이력 고유 PK
    upload_type VARCHAR(50),                           -- 업로드 대상 (예: 'SCHOOL_INFO', 'ZONE_INFO')
    original_file_name VARCHAR(255),                   -- 업로드한 엑셀 파일명
    stored_file_name VARCHAR(255),                     -- 서버에 보관된 엑셀 파일명 (검증용 보관)
    total_count INTEGER DEFAULT 0,                     -- 엑셀 내 전체 데이터 행 개수
    success_count INTEGER DEFAULT 0,                   -- DB 반영 성공 개수
    fail_count INTEGER DEFAULT 0,                      -- 오류로 인한 반영 실패 개수
    uploaded_by BIGINT,                                -- 업로드 실행자 ID
    uploaded_by_name VARCHAR(100),                     -- 업로드 실행자 이름
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP    -- 업로드 처리 일시
);

-- ==============================================================================
-- [테이블] 8. 시스템 감사/활동 로그 (tb_system_log)
-- 보안 및 감사 목적을 위해 사용자의 주요 시스템 이용 내역(로그인, 데이터 삭제 등) 기록
-- ==============================================================================
CREATE TABLE IF NOT EXISTS tb_system_log (
    log_id BIGSERIAL PRIMARY KEY,                      -- 로그 고유 PK
    log_type VARCHAR(50),                              -- 로그 분류 (LOGIN, CREATE, UPDATE, DELETE, EXPORT 등)
    action_name VARCHAR(100),                          -- 수행한 작업명 (예: '학구도 형상 변경', '엑셀 다운로드')
    actor_id BIGINT,                                   -- 작업을 수행한 사용자 ID
    actor_name VARCHAR(100),                           -- 작업을 수행한 사용자 이름
    ip_address VARCHAR(50),                            -- 접속 IP 주소
    request_url TEXT,                                  -- 요청 API 또는 화면 URL
    message TEXT,                                      -- 추가 상세 메시지 또는 에러 내역
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP     -- 로그 발생 일시
);

-- ==============================================================================
-- [트리거 설정] 데이터 수정 시 updated_at 자동 갱신 트리거 연결
-- ==============================================================================
-- 사용자 테이블
DROP TRIGGER IF EXISTS trg_user_updated_at ON tb_user;
CREATE TRIGGER trg_user_updated_at BEFORE UPDATE ON tb_user FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

-- 학교 기본 정보 테이블
DROP TRIGGER IF EXISTS trg_school_updated_at ON tb_school;
CREATE TRIGGER trg_school_updated_at BEFORE UPDATE ON tb_school FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

-- 학구도 작업 요청 테이블
DROP TRIGGER IF EXISTS trg_zone_request_updated_at ON tb_school_zone_request;
CREATE TRIGGER trg_zone_request_updated_at BEFORE UPDATE ON tb_school_zone_request FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

-- 공지사항 테이블
DROP TRIGGER IF EXISTS trg_notice_updated_at ON tb_notice;
CREATE TRIGGER trg_notice_updated_at BEFORE UPDATE ON tb_notice FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();