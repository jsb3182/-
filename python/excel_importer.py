"""
학구 변경 엑셀 데이터를 PostgreSQL에 적재하는 1차 MVP 스크립트입니다.

원칙:
1. 좌표가 있는 학교현황 데이터는 EPSG:5186 X/Y로 저장합니다.
2. 학구 변경 요청은 tb_school_zone_request에 저장합니다.
3. 실제 운영 전에는 엑셀 컬럼명을 최종 파일 기준으로 1회 더 교차검증하세요.
"""

import os
import pandas as pd
import psycopg2
from dotenv import load_dotenv

load_dotenv()

DB = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": os.getenv("DB_PORT", "5432"),
    "dbname": os.getenv("DB_NAME", "schoolzone_mvp"),
    "user": os.getenv("DB_USER", "postgres"),
    "password": os.getenv("DB_PASSWORD", "postgres"),
}

EXCEL_PATH = os.getenv("EXCEL_PATH", "학구변경.xlsx")

# 엑셀 컬럼명과 DB 컬럼명을 연결하는 매핑입니다.
ZONE_REQUEST_COLUMN_MAP = {
    "신청번호": "apply_no",
    "등록형태": "register_type",
    "등록형태상세": "register_detail",
    "학구명": "zone_name",
    "고시학구명": "announced_zone_name",
    "시도교육청": "education_office",
    "교육지원청": "support_office",
    "학교급": "school_level",
    "학구종류": "zone_type",
    "등록일자": "register_date",
    "시행년월": "effective_month",
    "진행상태": "progress_status",
    "담당부서": "department_name",
    "담당자명": "manager_name",
    "전화번호": "phone_number",
    "전자우편": "email",
    "요청사항": "request_content",
    "URL": "source_url",
    "작업자": "worker_name",
}


def clean_value(value):
    """NaN을 None으로 바꿔 DB INSERT 오류를 줄입니다."""
    if pd.isna(value):
        return None
    return str(value).strip()


def import_zone_requests(sheet_name="최신데이터"):
    """엑셀의 최신데이터 시트를 학구 변경 요청 테이블에 적재합니다."""
    df = pd.read_excel(EXCEL_PATH, sheet_name=sheet_name, dtype=str)
    df = df.rename(columns=ZONE_REQUEST_COLUMN_MAP)

    db_columns = list(ZONE_REQUEST_COLUMN_MAP.values())
    existing_columns = [c for c in db_columns if c in df.columns]

    sql = f"""
        INSERT INTO tb_school_zone_request ({', '.join(existing_columns)})
        VALUES ({', '.join(['%s'] * len(existing_columns))})
    """

    conn = psycopg2.connect(**DB)
    try:
        with conn:
            with conn.cursor() as cur:
                for _, row in df.iterrows():
                    values = [clean_value(row.get(col)) for col in existing_columns]
                    cur.execute(sql, values)
        print(f"적재 완료: {len(df)}건")
    finally:
        conn.close()


if __name__ == "__main__":
    import_zone_requests()
