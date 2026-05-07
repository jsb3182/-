-- =========================================================
-- GIS 학구도 자동 관리시스템 - Python 자동 동기화 DB 스키마
-- PostgreSQL + PostGIS
-- 좌표계 정책: EPSG:5186 통일
-- =========================================================

CREATE EXTENSION IF NOT EXISTS postgis;

-- 1. 동기화 실행 이력
CREATE TABLE IF NOT EXISTS sync_run (
    run_id BIGSERIAL PRIMARY KEY,
    source_file TEXT NOT NULL,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    finished_at TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'RUNNING',
    message TEXT,
    inserted_count INTEGER NOT NULL DEFAULT 0,
    updated_count INTEGER NOT NULL DEFAULT 0,
    deactivated_count INTEGER NOT NULL DEFAULT 0,
    unchanged_count INTEGER NOT NULL DEFAULT 0
);

-- 2. 6개 시트 원본 보존 테이블
CREATE TABLE IF NOT EXISTS sync_sheet_record (
    sheet_name VARCHAR(100) NOT NULL,
    source_key VARCHAR(128) NOT NULL,
    row_no INTEGER,
    row_hash VARCHAR(64) NOT NULL,
    data JSONB NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    first_seen_run_id BIGINT REFERENCES sync_run(run_id),
    last_seen_run_id BIGINT REFERENCES sync_run(run_id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (sheet_name, source_key)
);

CREATE INDEX IF NOT EXISTS idx_sync_sheet_record_sheet_active
ON sync_sheet_record(sheet_name, is_active);

CREATE INDEX IF NOT EXISTS idx_sync_sheet_record_data_gin
ON sync_sheet_record USING GIN(data);

-- 3. 변경 로그
CREATE TABLE IF NOT EXISTS sync_change_log (
    log_id BIGSERIAL PRIMARY KEY,
    run_id BIGINT NOT NULL REFERENCES sync_run(run_id),
    sheet_name VARCHAR(100) NOT NULL,
    source_key VARCHAR(128) NOT NULL,
    change_type VARCHAR(30) NOT NULL,
    before_hash VARCHAR(64),
    after_hash VARCHAR(64),
    before_data JSONB,
    after_data JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_sync_change_log_run
ON sync_change_log(run_id);

CREATE INDEX IF NOT EXISTS idx_sync_change_log_sheet
ON sync_change_log(sheet_name, change_type);

-- 4. 학구 변경 요청 핵심 업무 테이블
CREATE TABLE IF NOT EXISTS tb_zone_request (
    zone_request_id BIGSERIAL PRIMARY KEY,
    source_sheet VARCHAR(100) NOT NULL,
    source_key VARCHAR(128) NOT NULL,
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
    progress_status VARCHAR(30),
    worker_name VARCHAR(100),
    department_name VARCHAR(100),
    manager_name VARCHAR(100),
    phone_number VARCHAR(50),
    email VARCHAR(150),
    request_content TEXT,
    source_url TEXT,
    raw_data JSONB NOT NULL,
    row_hash VARCHAR(64) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(source_sheet, source_key)
);

CREATE INDEX IF NOT EXISTS idx_tb_zone_request_status
ON tb_zone_request(progress_status, is_active);

CREATE INDEX IF NOT EXISTS idx_tb_zone_request_zone_name
ON tb_zone_request(zone_name);

CREATE INDEX IF NOT EXISTS idx_tb_zone_request_office
ON tb_zone_request(education_office, support_office);

-- 5. 학교현황 확장 대비 테이블
-- 학구현황 기능은 1차 MVP에서 제외하지만, 학교 위치 저장은 EPSG:5186으로 준비합니다.
CREATE TABLE IF NOT EXISTS tb_school_status (
    school_id BIGSERIAL PRIMARY KEY,
    school_code VARCHAR(50),
    school_name VARCHAR(200) NOT NULL,
    school_level VARCHAR(50),
    education_office VARCHAR(100),
    support_office VARCHAR(100),
    road_address TEXT,
    jibun_address TEXT,
    x_coord NUMERIC(15,3),
    y_coord NUMERIC(15,3),
    geom geometry(Point, 5186),
    raw_data JSONB,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_tb_school_status_geom
ON tb_school_status USING GIST(geom);

CREATE INDEX IF NOT EXISTS idx_tb_school_status_name
ON tb_school_status(school_name);

-- 6. 프론트 공지사항 예비 테이블
CREATE TABLE IF NOT EXISTS tb_notice (
    notice_id BIGSERIAL PRIMARY KEY,
    title VARCHAR(300) NOT NULL,
    content TEXT NOT NULL,
    writer_name VARCHAR(100),
    notice_type VARCHAR(50) DEFAULT '일반',
    fixed_yn CHAR(1) DEFAULT 'N',
    view_count INTEGER DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
