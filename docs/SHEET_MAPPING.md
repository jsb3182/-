# 6개 시트 → Vue 메뉴 매핑

| 엑셀 시트 | Vue 경로 | 기능 |
|---|---|---|
| 종합 현황판 | `/sheet/summary` | 전체 현황 대시보드 |
| 일일 진척도 통계 | `/sheet/daily-progress` | 날짜별 진행 통계 |
| 상세작업관리 | `/sheet/work-management` | 작업자/진행상태 관리 |
| 최신데이터 | `/sheet/latest-data` | 최신 업로드 원천 데이터 |
| 신설코드 관리발급 | `/sheet/code-issuance` | 신설 학구 코드 관리 |
| 수정 이력 | `/sheet/edit-history` | DB 동기화/수정 이력 |

## 디자인 방향

- 첫 번째 참고 이미지의 큰 히어로 영역, CTA 버튼, 카드형 레이아웃을 반영했습니다.
- 마지막 참고 이미지의 학구도 관리시스템형 Navbar, 공지사항, 학구등록 테이블, 운영현황 카드 구조를 반영했습니다.
- 커스텀 CSS 파일과 `<style>` 태그는 사용하지 않고 Bootstrap 5 클래스만 사용했습니다.
