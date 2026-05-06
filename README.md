# GIS 학구도 자동 관리시스템 1차 MVP

## 최종 확정 범위
- 로그인/권한
- 대시보드
- 학구 변경 요청 관리
- 상세 작업 관리
- 진행상태 변경/이력 관리
- 학교현황
- 공지사항
- 엑셀 업로드/다운로드
- PostGIS 좌표계 EPSG:5186 통일

## 제외 범위
- 학구현황 메뉴
- 웹 지도 편집
- 학구 폴리곤 직접 수정
- GeoServer 연동
- 공간검증 자동화

## 폴더 구조
```text
backend/   Spring Boot + 전자정부프레임워크 확장 준비 구조
frontend/  Vue 3 + Bootstrap 5
python/    엑셀 업로드/정제 자동화 스크립트
database/  PostgreSQL + PostGIS DDL/Seed SQL
docs/      로드맵 및 API 요약
```

## 실행 순서
1. database/01_schema.sql 실행
2. database/02_seed.sql 실행
3. backend 실행
4. frontend 실행
5. python/excel_importer.py로 엑셀 적재 테스트

## 좌표계 원칙
모든 공간 저장/분석 좌표계는 EPSG:5186입니다.
