"""
GIS 학구도 자동 관리시스템 - 엑셀/CSV 자동 DB 동기화 스크립트
================================================================

역할
----
1. 사용자가 최신 학구 변경 엑셀/CSV 파일을 input 폴더에 넣거나 경로를 직접 지정합니다.
2. 이 스크립트가 6개 시트 데이터를 읽습니다.
3. PostgreSQL/PostGIS DB의 기존 데이터와 신규 파일 데이터를 비교합니다.
4. 신규 데이터는 INSERT, 변경 데이터는 UPDATE, 사라진 데이터는 DELETE 대신 비활성화합니다.
5. 모든 변경 결과는 sync_change_log 테이블에 기록합니다.

중요 정책
---------
- 1차 MVP에서 학구현황 기능은 제외합니다.
- 좌표계는 EPSG:5186으로 통일합니다.
- 학구 변경 요청/상세작업관리는 tb_zone_request에 정규화 저장합니다.
- 6개 시트 원본은 sync_sheet_record.data JSONB에 보존합니다.
- 운영 데이터에는 개인정보/업무정보가 포함될 수 있으므로 GitHub에는 원본 파일을 올리지 마세요.

실행 순서
---------
1) PostgreSQL DB 생성
   createdb gis_schoolzone

2) 스키마 생성
   psql -h localhost -U postgres -d gis_schoolzone -f ../database/schema.sql

3) 라이브러리 설치
   pip install -r requirements.txt

4) .env 생성
   copy .env.example .env

5) 변경 건수만 확인
   python sync_schoolzone.py --input ../input/학구변경_20260318100156941.xlsx --dry-run

6) 실제 반영
   python sync_schoolzone.py --input ../input/학구변경_20260318100156941.xlsx --apply

CSV 단일 파일 예시
------------------
python sync_schoolzone.py --input "../input/학구변경_20260318100156941 - 상세작업관리.csv" --sheet-name 상세작업관리 --apply
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine


# =========================================================
# 1. 시트 정의
# =========================================================

EXPECTED_SHEETS = [
    "종합 현황판",
    "일일 진척도 통계",
    "상세작업관리",
    "최신데이터",
    "신설코드 관리발급",
    "수정 이력",
]

# 시트별 고유키 후보 컬럼입니다.
# 후보 컬럼이 없으면 행 전체 해시를 source_key로 사용합니다.
SHEET_KEY_CANDIDATES: Dict[str, List[str]] = {
    "종합 현황판": ["진행상태"],
    "일일 진척도 통계": ["날짜"],
    "상세작업관리": ["신청번호", "학구명", "NO"],
    "최신데이터": ["신청번호", "학구명", "번호"],
    "신설코드 관리발급": ["일련번", "신설코드", "학구명"],
    "수정 이력": ["날짜", "업데이트", "작업자"],
}

# 엑셀마다 병합 셀/상단 제목이 있을 수 있어 시트별 헤더 행을 조정합니다.
SHEET_HEADER_ROW: Dict[str, int] = {
    "종합 현황판": 1,
    "일일 진척도 통계": 0,
    "상세작업관리": 0,
    "최신데이터": 0,
    "신설코드 관리발급": 1,
    "수정 이력": 0,
}


@dataclass
class SyncStats:
    """시트별 동기화 결과 건수를 담는 단순 데이터 클래스입니다."""
    inserted: int = 0
    updated: int = 0
    deactivated: int = 0
    unchanged: int = 0

    def add(self, other: "SyncStats") -> None:
        self.inserted += other.inserted
        self.updated += other.updated
        self.deactivated += other.deactivated
        self.unchanged += other.unchanged


# =========================================================
# 2. DB 연결
# =========================================================

def build_engine() -> Engine:
    """
    .env 또는 운영 환경변수에서 PostgreSQL 접속 정보를 읽어 DB 엔진을 생성합니다.

    운영에서는 .env 파일 대신 서버 환경변수 또는 Secret Manager를 사용하는 것을 권장합니다.
    """
    load_dotenv()

    host = os.getenv("DB_HOST", "localhost")
    port = os.getenv("DB_PORT", "5432")
    db = os.getenv("DB_NAME", "gis_schoolzone")
    user = os.getenv("DB_USER", "postgres")
    password = os.getenv("DB_PASSWORD", "postgres")

    url = f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}"
    return create_engine(url, pool_pre_ping=True, future=True)


# =========================================================
# 3. 데이터 정리 유틸
# =========================================================

def normalize_column_name(value: Any, fallback_index: int) -> str:
    """엑셀/CSV 컬럼명을 DB 저장에 안전한 값으로 정리합니다."""
    if value is None or str(value).strip() == "" or str(value).startswith("Unnamed"):
        return f"col_{fallback_index}"

    name = str(value).strip()
    name = re.sub(r"\s+", " ", name)
    name = name.replace("\n", " ")
    return name


def make_unique_columns(columns: Iterable[Any]) -> List[str]:
    """중복 컬럼명이 있을 경우 _2, _3을 붙여 유일한 컬럼명으로 만듭니다."""
    result: List[str] = []
    counts: Dict[str, int] = {}

    for idx, col in enumerate(columns, start=1):
        base = normalize_column_name(col, idx)
        counts[base] = counts.get(base, 0) + 1
        result.append(base if counts[base] == 1 else f"{base}_{counts[base]}")

    return result


def clean_value(value: Any) -> Any:
    """NaN, Timestamp 등 JSONB 저장에 불편한 값을 안전하게 변환합니다."""
    if pd.isna(value):
        return None
    if isinstance(value, pd.Timestamp):
        return value.strftime("%Y-%m-%d")
    if isinstance(value, datetime):
        return value.strftime("%Y-%m-%d")
    if isinstance(value, float):
        return int(value) if value.is_integer() else value
    if isinstance(value, str):
        value = value.strip()
        return value if value else None
    return value


def normalize_dataframe(df: pd.DataFrame) -> pd.DataFrame:
    """빈 행/빈 열 제거, 컬럼명 정리, 값 정규화를 한 번에 수행합니다."""
    df = df.copy()
    df.columns = make_unique_columns(df.columns)
    df = df.dropna(how="all")
    df = df.dropna(axis=1, how="all")
    df = df.reset_index(drop=True)

    for col in df.columns:
        df[col] = df[col].map(clean_value)

    return df


def read_excel_sheet(path: Path, sheet_name: str) -> pd.DataFrame:
    """엑셀 파일에서 지정한 시트만 읽습니다."""
    header_row = SHEET_HEADER_ROW.get(sheet_name, 0)
    df = pd.read_excel(path, sheet_name=sheet_name, header=header_row, engine="openpyxl")
    return normalize_dataframe(df)


def read_csv_file(path: Path) -> pd.DataFrame:
    """CSV 파일 인코딩을 한국 업무 파일 기준으로 순차 시도합니다."""
    encodings = ["utf-8-sig", "cp949", "euc-kr", "utf-8"]
    last_error: Optional[Exception] = None

    for enc in encodings:
        try:
            return normalize_dataframe(pd.read_csv(path, encoding=enc))
        except Exception as exc:  # noqa: BLE001
            last_error = exc

    raise RuntimeError(f"CSV 파일을 읽을 수 없습니다: {path} / 마지막 오류: {last_error}")


def dataframe_to_records(df: pd.DataFrame, sheet_name: str) -> List[Dict[str, Any]]:
    """DataFrame을 DB 비교용 레코드 목록으로 변환합니다."""
    records: List[Dict[str, Any]] = []

    for idx, row in df.iterrows():
        data = {col: clean_value(row[col]) for col in df.columns}

        # 값이 전부 비어 있는 행은 동기화 대상에서 제외합니다.
        if all(value is None for value in data.values()):
            continue

        source_key = make_source_key(sheet_name, data, idx + 1)
        row_hash = make_row_hash(data)

        records.append({
            "sheet_name": sheet_name,
            "source_key": source_key,
            "row_no": idx + 1,
            "row_hash": row_hash,
            "data": data,
        })

    return records


def make_source_key(sheet_name: str, data: Dict[str, Any], row_no: int) -> str:
    """시트별 업무 키를 해시화하여 source_key로 사용합니다."""
    candidates = SHEET_KEY_CANDIDATES.get(sheet_name, [])
    parts: List[str] = []

    for col in candidates:
        value = data.get(col)
        if value is not None:
            parts.append(f"{col}={value}")

    raw_key = "|".join(parts) if parts else f"row={row_no}|hash={make_row_hash(data)}"
    return hashlib.sha256(raw_key.encode("utf-8")).hexdigest()


def make_row_hash(data: Dict[str, Any]) -> str:
    """행 전체 값을 해시화해 변경 여부를 빠르게 판단합니다."""
    raw = json.dumps(data, ensure_ascii=False, sort_keys=True, default=str)
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


def parse_date(value: Any) -> Optional[str]:
    """여러 날짜 표현을 PostgreSQL DATE용 YYYY-MM-DD 문자열로 변환합니다."""
    if value is None or value == "-":
        return None
    dt = pd.to_datetime(value, errors="coerce")
    if pd.isna(dt):
        return None
    return dt.strftime("%Y-%m-%d")


def pick(data: Dict[str, Any], *names: str) -> Any:
    """여러 후보 컬럼명 중 처음 발견되는 값을 반환합니다."""
    for name in names:
        if name in data and data.get(name) is not None:
            return data.get(name)
    return None


# =========================================================
# 4. DB 동기화
# =========================================================

def create_run(conn, source_file: str) -> int:
    result = conn.execute(
        text("INSERT INTO sync_run(source_file) VALUES (:source_file) RETURNING run_id"),
        {"source_file": source_file},
    )
    return int(result.scalar_one())


def finish_run(conn, run_id: int, status: str, message: str, stats: SyncStats) -> None:
    conn.execute(
        text("""
            UPDATE sync_run
            SET finished_at = CURRENT_TIMESTAMP,
                status = :status,
                message = :message,
                inserted_count = :inserted,
                updated_count = :updated,
                deactivated_count = :deactivated,
                unchanged_count = :unchanged
            WHERE run_id = :run_id
        """),
        {
            "run_id": run_id,
            "status": status,
            "message": message,
            "inserted": stats.inserted,
            "updated": stats.updated,
            "deactivated": stats.deactivated,
            "unchanged": stats.unchanged,
        },
    )


def load_existing_records(conn, sheet_name: str) -> Dict[str, Dict[str, Any]]:
    rows = conn.execute(
        text("""
            SELECT source_key, row_hash, data
            FROM sync_sheet_record
            WHERE sheet_name = :sheet_name AND is_active = TRUE
        """),
        {"sheet_name": sheet_name},
    ).mappings()

    return {row["source_key"]: dict(row) for row in rows}


def log_change(
    conn,
    run_id: int,
    sheet_name: str,
    source_key: str,
    change_type: str,
    before_hash: Optional[str],
    after_hash: Optional[str],
    before_data: Optional[Dict[str, Any]],
    after_data: Optional[Dict[str, Any]],
) -> None:
    """INSERT/UPDATE/DEACTIVATE 변경 내역을 모두 로그로 저장합니다."""
    conn.execute(
        text("""
            INSERT INTO sync_change_log(
                run_id, sheet_name, source_key, change_type,
                before_hash, after_hash, before_data, after_data
            )
            VALUES (
                :run_id, :sheet_name, :source_key, :change_type,
                :before_hash, :after_hash, CAST(:before_data AS JSONB), CAST(:after_data AS JSONB)
            )
        """),
        {
            "run_id": run_id,
            "sheet_name": sheet_name,
            "source_key": source_key,
            "change_type": change_type,
            "before_hash": before_hash,
            "after_hash": after_hash,
            "before_data": json.dumps(before_data, ensure_ascii=False, default=str) if before_data is not None else None,
            "after_data": json.dumps(after_data, ensure_ascii=False, default=str) if after_data is not None else None,
        },
    )


def sync_sheet(conn, run_id: int, sheet_name: str, records: List[Dict[str, Any]], dry_run: bool) -> SyncStats:
    """단일 시트 단위로 INSERT/UPDATE/DEACTIVATE/UNCHANGED를 판정합니다."""
    stats = SyncStats()
    existing = load_existing_records(conn, sheet_name)
    incoming_keys = {record["source_key"] for record in records}

    for record in records:
        key = record["source_key"]
        old = existing.get(key)

        if old is None:
            stats.inserted += 1
            if not dry_run:
                conn.execute(
                    text("""
                        INSERT INTO sync_sheet_record(
                            sheet_name, source_key, row_no, row_hash, data,
                            is_active, first_seen_run_id, last_seen_run_id
                        )
                        VALUES (
                            :sheet_name, :source_key, :row_no, :row_hash,
                            CAST(:data AS JSONB), TRUE, :run_id, :run_id
                        )
                    """),
                    {
                        "sheet_name": sheet_name,
                        "source_key": key,
                        "row_no": record["row_no"],
                        "row_hash": record["row_hash"],
                        "data": json.dumps(record["data"], ensure_ascii=False, default=str),
                        "run_id": run_id,
                    },
                )
                log_change(conn, run_id, sheet_name, key, "INSERT", None, record["row_hash"], None, record["data"])
                upsert_zone_request_if_possible(conn, sheet_name, record)

        elif old["row_hash"] != record["row_hash"]:
            stats.updated += 1
            if not dry_run:
                conn.execute(
                    text("""
                        UPDATE sync_sheet_record
                        SET row_no = :row_no,
                            row_hash = :row_hash,
                            data = CAST(:data AS JSONB),
                            is_active = TRUE,
                            last_seen_run_id = :run_id,
                            updated_at = CURRENT_TIMESTAMP
                        WHERE sheet_name = :sheet_name AND source_key = :source_key
                    """),
                    {
                        "sheet_name": sheet_name,
                        "source_key": key,
                        "row_no": record["row_no"],
                        "row_hash": record["row_hash"],
                        "data": json.dumps(record["data"], ensure_ascii=False, default=str),
                        "run_id": run_id,
                    },
                )
                log_change(conn, run_id, sheet_name, key, "UPDATE", old["row_hash"], record["row_hash"], old["data"], record["data"])
                upsert_zone_request_if_possible(conn, sheet_name, record)

        else:
            stats.unchanged += 1
            if not dry_run:
                conn.execute(
                    text("""
                        UPDATE sync_sheet_record
                        SET last_seen_run_id = :run_id,
                            updated_at = CURRENT_TIMESTAMP
                        WHERE sheet_name = :sheet_name AND source_key = :source_key
                    """),
                    {"run_id": run_id, "sheet_name": sheet_name, "source_key": key},
                )

    # 새 파일에서 사라진 기존 데이터는 삭제하지 않고 비활성화합니다.
    missing_keys = set(existing.keys()) - incoming_keys
    for missing_key in missing_keys:
        old = existing[missing_key]
        stats.deactivated += 1
        if not dry_run:
            conn.execute(
                text("""
                    UPDATE sync_sheet_record
                    SET is_active = FALSE,
                        last_seen_run_id = :run_id,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE sheet_name = :sheet_name AND source_key = :source_key
                """),
                {"run_id": run_id, "sheet_name": sheet_name, "source_key": missing_key},
            )
            log_change(conn, run_id, sheet_name, missing_key, "DEACTIVATE", old["row_hash"], None, old["data"], None)
            deactivate_zone_request_if_possible(conn, sheet_name, missing_key)

    return stats


def upsert_zone_request_if_possible(conn, sheet_name: str, record: Dict[str, Any]) -> None:
    """최신데이터/상세작업관리는 업무 핵심 테이블에도 저장합니다."""
    if sheet_name not in {"최신데이터", "상세작업관리"}:
        return

    data = record["data"]

    conn.execute(
        text("""
            INSERT INTO tb_zone_request(
                source_sheet, source_key, request_no, apply_no,
                register_type, register_detail, zone_name, announced_zone_name,
                education_office, support_office, school_level, zone_type,
                register_date, effective_month, progress_status, worker_name,
                department_name, manager_name, phone_number, email,
                request_content, source_url, raw_data, row_hash, is_active,
                updated_at
            )
            VALUES(
                :source_sheet, :source_key, :request_no, :apply_no,
                :register_type, :register_detail, :zone_name, :announced_zone_name,
                :education_office, :support_office, :school_level, :zone_type,
                :register_date, :effective_month, :progress_status, :worker_name,
                :department_name, :manager_name, :phone_number, :email,
                :request_content, :source_url, CAST(:raw_data AS JSONB), :row_hash, TRUE,
                CURRENT_TIMESTAMP
            )
            ON CONFLICT(source_sheet, source_key)
            DO UPDATE SET
                request_no = EXCLUDED.request_no,
                apply_no = EXCLUDED.apply_no,
                register_type = EXCLUDED.register_type,
                register_detail = EXCLUDED.register_detail,
                zone_name = EXCLUDED.zone_name,
                announced_zone_name = EXCLUDED.announced_zone_name,
                education_office = EXCLUDED.education_office,
                support_office = EXCLUDED.support_office,
                school_level = EXCLUDED.school_level,
                zone_type = EXCLUDED.zone_type,
                register_date = EXCLUDED.register_date,
                effective_month = EXCLUDED.effective_month,
                progress_status = EXCLUDED.progress_status,
                worker_name = EXCLUDED.worker_name,
                department_name = EXCLUDED.department_name,
                manager_name = EXCLUDED.manager_name,
                phone_number = EXCLUDED.phone_number,
                email = EXCLUDED.email,
                request_content = EXCLUDED.request_content,
                source_url = EXCLUDED.source_url,
                raw_data = EXCLUDED.raw_data,
                row_hash = EXCLUDED.row_hash,
                is_active = TRUE,
                updated_at = CURRENT_TIMESTAMP
        """),
        {
            "source_sheet": sheet_name,
            "source_key": record["source_key"],
            "request_no": str(pick(data, "번호", "NO", "순번") or "") or None,
            "apply_no": str(pick(data, "신청번호", "접수번호") or "") or None,
            "register_type": pick(data, "등록형태"),
            "register_detail": pick(data, "등록형태(상세)", "등록형태 상세"),
            "zone_name": pick(data, "학구명"),
            "announced_zone_name": pick(data, "고시학구명"),
            "education_office": pick(data, "시도교육청"),
            "support_office": pick(data, "교육지원청", "지역"),
            "school_level": pick(data, "학교급"),
            "zone_type": pick(data, "학구종류"),
            "register_date": parse_date(pick(data, "등록일자", "등록일")),
            "effective_month": str(pick(data, "시행년월") or "") or None,
            "progress_status": pick(data, "진행상태", "신청상태"),
            "worker_name": pick(data, "작업자"),
            "department_name": pick(data, "담당부서"),
            "manager_name": pick(data, "담당자명", "담당자"),
            "phone_number": pick(data, "전화번호"),
            "email": pick(data, "전자우편", "이메일"),
            "request_content": pick(data, "요청사항", "내용"),
            "source_url": pick(data, "URL", "url"),
            "raw_data": json.dumps(data, ensure_ascii=False, default=str),
            "row_hash": record["row_hash"],
        },
    )


def deactivate_zone_request_if_possible(conn, sheet_name: str, source_key: str) -> None:
    """업무 핵심 테이블의 요청 건도 비활성화합니다."""
    if sheet_name not in {"최신데이터", "상세작업관리"}:
        return

    conn.execute(
        text("""
            UPDATE tb_zone_request
            SET is_active = FALSE,
                updated_at = CURRENT_TIMESTAMP
            WHERE source_sheet = :source_sheet AND source_key = :source_key
        """),
        {"source_sheet": sheet_name, "source_key": source_key},
    )


# =========================================================
# 5. 입력 파일 처리
# =========================================================

def load_input_records(input_path: Path, sheet_name: Optional[str]) -> Dict[str, List[Dict[str, Any]]]:
    """엑셀 또는 CSV 파일을 읽어 시트별 레코드 목록으로 반환합니다."""
    if not input_path.exists():
        raise FileNotFoundError(f"입력 파일이 없습니다: {input_path}")

    suffix = input_path.suffix.lower()
    result: Dict[str, List[Dict[str, Any]]] = {}

    if suffix in {".xlsx", ".xlsm", ".xls"}:
        available_sheets = pd.ExcelFile(input_path).sheet_names
        target_sheets = [sheet_name] if sheet_name else [s for s in EXPECTED_SHEETS if s in available_sheets]

        for sheet in target_sheets:
            df = read_excel_sheet(input_path, sheet)
            result[sheet] = dataframe_to_records(df, sheet)

    elif suffix == ".csv":
        inferred_name = sheet_name or infer_sheet_name_from_filename(input_path.name)
        df = read_csv_file(input_path)
        result[inferred_name] = dataframe_to_records(df, inferred_name)

    else:
        raise ValueError(f"지원하지 않는 파일 형식입니다: {suffix}")

    return result


def infer_sheet_name_from_filename(filename: str) -> str:
    """파일명에 포함된 시트명으로 CSV의 논리 시트명을 추정합니다."""
    for sheet in EXPECTED_SHEETS:
        if sheet in filename:
            return sheet
    return "CSV데이터"


def print_plan(records_by_sheet: Dict[str, List[Dict[str, Any]]]) -> None:
    """실행 전 입력 데이터 개요를 출력합니다."""
    print("\n[입력 파일 분석 결과]")
    for sheet, records in records_by_sheet.items():
        print(f"- {sheet}: {len(records):,}건")


# =========================================================
# 6. 메인 실행부
# =========================================================

def main() -> int:
    parser = argparse.ArgumentParser(description="GIS 학구도 엑셀/CSV 자동 DB 동기화")
    parser.add_argument("--input", required=False, default=os.getenv("INPUT_FILE"), help="입력 엑셀/CSV 파일 경로")
    parser.add_argument("--sheet-name", required=False, help="특정 시트 또는 CSV 시트명 지정")
    parser.add_argument("--dry-run", action="store_true", help="DB 반영 없이 변경 건수만 계산")
    parser.add_argument("--apply", action="store_true", help="실제 DB 반영")
    args = parser.parse_args()

    if not args.input:
        print("오류: --input 파일 경로가 필요합니다.", file=sys.stderr)
        return 1

    if not args.dry_run and not args.apply:
        print("안전상 기본값은 실행하지 않습니다. --dry-run 또는 --apply 중 하나를 지정하세요.", file=sys.stderr)
        return 1

    input_path = Path(args.input).resolve()
    dry_run = bool(args.dry_run and not args.apply)

    records_by_sheet = load_input_records(input_path, args.sheet_name)
    print_plan(records_by_sheet)

    engine = build_engine()
    total = SyncStats()

    with engine.begin() as conn:
        run_id = create_run(conn, str(input_path))
        try:
            for sheet, records in records_by_sheet.items():
                sheet_stats = sync_sheet(conn, run_id, sheet, records, dry_run=dry_run)
                total.add(sheet_stats)
                print(
                    f"[동기화 결과] {sheet} | "
                    f"INSERT {sheet_stats.inserted:,}, UPDATE {sheet_stats.updated:,}, "
                    f"DEACTIVATE {sheet_stats.deactivated:,}, UNCHANGED {sheet_stats.unchanged:,}"
                )

            status = "DRY_RUN" if dry_run else "SUCCESS"
            message = "변경 건수만 계산했습니다." if dry_run else "DB 동기화를 완료했습니다."
            finish_run(conn, run_id, status, message, total)

        except Exception as exc:
            finish_run(conn, run_id, "FAILED", str(exc), total)
            raise

    print("\n[전체 결과]")
    print(f"- INSERT: {total.inserted:,}")
    print(f"- UPDATE: {total.updated:,}")
    print(f"- DEACTIVATE: {total.deactivated:,}")
    print(f"- UNCHANGED: {total.unchanged:,}")
    print("\n완료")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
