-- GIS 학구도 자동 관리시스템 1차 MVP DB 스키마
-- 좌표계: EPSG:5186 통일

CREATE EXTENSION IF NOT EXISTS postgis;

-- 수정일 자동 갱신 함수
CREATE OR REPLACE FUNCTION fn_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS tb_user (
    user_id BIGSERIAL PRIMARY KEY,
    login_id VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    user_name VARCHAR(100) NOT NULL,
    role VARCHAR(30) NOT NULL CHECK (role IN ('ADMIN','MANAGER','WORKER','VIEWER')),
    department_name VARCHAR(100),
    email VARCHAR(100),
    phone_number VARCHAR(50),
    use_yn CHAR(1) DEFAULT 'Y' CHECK (use_yn IN ('Y','N')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tb_school (
    school_id BIGSERIAL PRIMARY KEY,
    school_code VARCHAR(50),
    school_name VARCHAR(200) NOT NULL,
    school_level VARCHAR(50),
    establish_type VARCHAR(50),
    operation_status VARCHAR(50),
    education_office VARCHAR(100),
    support_office VARCHAR(100),
    road_address TEXT,
    jibun_address TEXT,
    x_coord NUMERIC(15,3),
    y_coord NUMERIC(15,3),
    geom geometry(Point, 5186),
    use_yn CHAR(1) DEFAULT 'Y' CHECK (use_yn IN ('Y','N')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_tb_school_geom ON tb_school USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_tb_school_name ON tb_school (school_name);
CREATE INDEX IF NOT EXISTS idx_tb_school_office ON tb_school (education_office, support_office);

CREATE TABLE IF NOT EXISTS tb_school_zone_request (
    request_id BIGSERIAL PRIMARY KEY,
    request_no VARCHAR(50),
    apply_no VARCHAR(50),
    register_type VARCHAR(50),
    register_detail VARCHAR(100),
    zone_name VARCHAR(200),
    announced_zone_name VARCHAR(200),
    education_office VARCHAR(100),
    support_office VARCHAR(100),
    school_level VARCHAR(50),
    zone_type VARCHAR(100),
    register_date DATE,
    effective_month VARCHAR(20),
    progress_status VARCHAR(30) DEFAULT '등록' CHECK (progress_status IN ('등록','접수','작업','검토','적용','완료','취소','재요청')),
    worker_id BIGINT,
    worker_name VARCHAR(100),
    department_name VARCHAR(100),
    manager_name VARCHAR(100),
    phone_number VARCHAR(50),
    email VARCHAR(100),
    request_content TEXT,
    source_url TEXT,
    work_memo TEXT,
    review_memo TEXT,
    use_yn CHAR(1) DEFAULT 'Y' CHECK (use_yn IN ('Y','N')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_zone_request_status ON tb_school_zone_request(progress_status);
CREATE INDEX IF NOT EXISTS idx_zone_request_zone_name ON tb_school_zone_request(zone_name);
CREATE INDEX IF NOT EXISTS idx_zone_request_office ON tb_school_zone_request(education_office, support_office);
CREATE INDEX IF NOT EXISTS idx_zone_request_register_date ON tb_school_zone_request(register_date);

CREATE TABLE IF NOT EXISTS tb_request_status_history (
    history_id BIGSERIAL PRIMARY KEY,
    request_id BIGINT NOT NULL REFERENCES tb_school_zone_request(request_id),
    before_status VARCHAR(30),
    after_status VARCHAR(30),
    changed_by BIGINT,
    changed_by_name VARCHAR(100),
    change_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_status_history_request ON tb_request_status_history(request_id);

CREATE TABLE IF NOT EXISTS tb_notice (
    notice_id BIGSERIAL PRIMARY KEY,
    title VARCHAR(300) NOT NULL,
    content TEXT NOT NULL,
    writer_id BIGINT,
    writer_name VARCHAR(100),
    notice_type VARCHAR(50),
    fixed_yn CHAR(1) DEFAULT 'N' CHECK (fixed_yn IN ('Y','N')),
    view_count INTEGER DEFAULT 0,
    use_yn CHAR(1) DEFAULT 'Y' CHECK (use_yn IN ('Y','N')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_notice_fixed ON tb_notice(fixed_yn, created_at DESC);

CREATE TABLE IF NOT EXISTS tb_attachment_file (
    file_id BIGSERIAL PRIMARY KEY,
    target_type VARCHAR(50),
    target_id BIGINT,
    original_file_name VARCHAR(255),
    stored_file_name VARCHAR(255),
    file_path TEXT,
    file_size BIGINT,
    file_ext VARCHAR(20),
    uploaded_by BIGINT,
    uploaded_by_name VARCHAR(100),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_attachment_target ON tb_attachment_file(target_type, target_id);

CREATE TABLE IF NOT EXISTS tb_excel_upload_history (
    upload_id BIGSERIAL PRIMARY KEY,
    upload_type VARCHAR(50),
    original_file_name VARCHAR(255),
    stored_file_name VARCHAR(255),
    total_count INTEGER DEFAULT 0,
    success_count INTEGER DEFAULT 0,
    fail_count INTEGER DEFAULT 0,
    uploaded_by BIGINT,
    uploaded_by_name VARCHAR(100),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tb_system_log (
    log_id BIGSERIAL PRIMARY KEY,
    log_type VARCHAR(50),
    action_name VARCHAR(100),
    actor_id BIGINT,
    actor_name VARCHAR(100),
    ip_address VARCHAR(50),
    request_url TEXT,
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS trg_user_updated_at ON tb_user;
CREATE TRIGGER trg_user_updated_at BEFORE UPDATE ON tb_user FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

DROP TRIGGER IF EXISTS trg_school_updated_at ON tb_school;
CREATE TRIGGER trg_school_updated_at BEFORE UPDATE ON tb_school FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

DROP TRIGGER IF EXISTS trg_zone_request_updated_at ON tb_school_zone_request;
CREATE TRIGGER trg_zone_request_updated_at BEFORE UPDATE ON tb_school_zone_request FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

DROP TRIGGER IF EXISTS trg_notice_updated_at ON tb_notice;
CREATE TRIGGER trg_notice_updated_at BEFORE UPDATE ON tb_notice FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
