# GIS 학구도 자동 관리시스템 - Vue + Bootstrap + Python 동기화 MVP

이 프로젝트는 학구 변경 업무를 관리하기 위한 1차 MVP입니다.

## 확정 범위

포함:

- Vue.js 프론트엔드
- Bootstrap 5 기반 UI
- Python 엑셀/CSV 자동 DB 동기화
- PostgreSQL/PostGIS 스키마
- 6개 시트 페이지 매핑
- EPSG:5186 좌표계 정책

제외:

- 학구현황 기능
- 웹 지도 편집
- GeoServer 연동
- 학구 폴리곤 직접 수정

## 디렉토리 구조

```text
schoolzone-vue-bootstrap-sync
├─ backend
│  ├─ sync_schoolzone.py
│  ├─ requirements.txt
│  └─ .env.example
├─ database
│  └─ schema.sql
├─ frontend
│  ├─ package.json
│  ├─ vite.config.js
│  └─ src
│     ├─ App.vue
│     ├─ main.js
│     ├─ router
│     ├─ data
│     ├─ components
│     └─ views
├─ input
├─ output
├─ logs
└─ docs
```

## 프론트엔드 실행

```bash
cd frontend
npm install
npm run dev
```

접속:

```text
http://localhost:5173
```

## Python 동기화 실행

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
```

DB 스키마 생성:

```bash
createdb gis_schoolzone
psql -h localhost -U postgres -d gis_schoolzone -f ../database/schema.sql
```

동기화 미리보기:

```bash
python sync_schoolzone.py --input ../input/학구변경_20260318100156941.xlsx --dry-run
```

실제 반영:

```bash
python sync_schoolzone.py --input ../input/학구변경_20260318100156941.xlsx --apply
```

## Git 관리 주의사항

원본 엑셀, SHP, DB 백업, .env, 인증서, node_modules, dist, venv는 Git에 올리지 마세요.
