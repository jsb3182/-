<template>
  <section class="bg-white border-bottom">
    <div class="container py-5">
      <div class="row align-items-center g-5">
        <div class="col-lg-6">
          <div class="mb-4">
            <span class="badge text-bg-primary rounded-pill px-3 py-2">
              EPSG:5186 · 학구 변경 업무 자동화
            </span>
          </div>

          <h1 class="display-4 fw-bold lh-sm mb-4">
            공문. 정밀함. <br />
            학구 관리 자동화.
          </h1>

          <p class="lead text-secondary mb-4">
            엑셀 기반 학구 변경 데이터를 PostgreSQL/PostGIS로 자동 동기화하고,
            진행상태·공지사항·상세작업관리를 Vue 화면에서 관리합니다.
          </p>

          <div class="d-flex flex-wrap gap-2 mb-5">
            <RouterLink class="btn btn-primary btn-lg px-4" to="/sheet/work-management">
              작업 시작
              <i class="bi bi-arrow-right ms-2"></i>
            </RouterLink>
            <RouterLink class="btn btn-outline-dark btn-lg px-4" to="/sheet/summary">
              결과 보기
            </RouterLink>
          </div>

          <div class="card bg-primary-subtle border-0">
            <div class="card-body d-flex align-items-center gap-3">
              <button class="btn btn-light rounded-3">
                <i class="bi bi-play-fill fs-4 text-primary"></i>
              </button>
              <div>
                <p class="fw-bold mb-1">자동 동기화 흐름</p>
                <p class="text-secondary mb-0 small">
                  업로드 → 비교 → INSERT/UPDATE/비활성화 → 변경 이력 저장
                </p>
              </div>
            </div>
          </div>
        </div>

        <div class="col-lg-6">
          <div class="card border-0 shadow-lg">
            <div class="card-header bg-info text-white py-3">
              <div class="d-flex justify-content-between align-items-center">
                <h2 class="h5 mb-0 fw-bold">학구변경조회</h2>
                <span class="badge text-bg-light">MVP</span>
              </div>
            </div>

            <div class="card-body p-4">
              <div class="input-group mb-4">
                <input class="form-control form-control-lg" placeholder="학구명 또는 신청번호를 입력해 주세요." />
                <button class="btn btn-success px-4">검색</button>
              </div>

              <div class="row g-3">
                <div v-for="card in dashboardCards" :key="card.title" class="col-6">
                  <SummaryCard
                    :title="card.title"
                    :value="card.value"
                    :icon="card.icon"
                    :tone="card.tone"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <section class="container-fluid px-4 py-4">
    <div class="row g-4">
      <div class="col-xl-6">
        <div class="card border-0 shadow-sm h-100">
          <div class="card-header bg-white d-flex justify-content-between align-items-center">
            <h2 class="h5 text-success fw-bold mb-0">공지사항</h2>
            <RouterLink class="btn btn-sm btn-outline-secondary" to="/sheet/edit-history">
              더보기
            </RouterLink>
          </div>
          <div class="list-group list-group-flush">
            <a class="list-group-item list-group-item-action py-3" href="#">
              <div class="d-flex justify-content-between">
                <span class="fw-semibold">[공지] 2026년도 학구 변경자료 업로드 안내</span>
                <span class="text-muted small">2026-04-30</span>
              </div>
            </a>
            <a class="list-group-item list-group-item-action py-3" href="#">
              <div class="d-flex justify-content-between">
                <span class="fw-semibold">[공지] EPSG:5186 좌표계 통일 적용 안내</span>
                <span class="text-muted small">2026-02-27</span>
              </div>
            </a>
            <a class="list-group-item list-group-item-action py-3" href="#">
              <div class="d-flex justify-content-between">
                <span class="fw-semibold">[공지] 학구도 변경 요청 검토 절차 안내</span>
                <span class="text-muted small">2025-12-29</span>
              </div>
            </a>
          </div>
        </div>
      </div>

      <div class="col-xl-6">
        <div class="card border-0 shadow-sm h-100">
          <div class="card-header bg-white d-flex justify-content-between align-items-center">
            <h2 class="h5 text-success fw-bold mb-0">학구등록</h2>
            <RouterLink class="btn btn-sm btn-outline-secondary" to="/sheet/latest-data">
              더보기
            </RouterLink>
          </div>
          <DataTable
            :columns="['시도', '지역', '등록형태', '학구명', '신청상태', '등록일자']"
            :rows="registrationRows"
          />
        </div>
      </div>

      <div class="col-xl-6">
        <div class="card border-0 shadow-sm h-100">
          <div class="card-header bg-white">
            <h2 class="h5 text-success fw-bold mb-0">학교·학구 현황조사</h2>
          </div>
          <div class="list-group list-group-flush">
            <a class="list-group-item list-group-item-action py-3" href="#">
              2026년도 초·중등학교 현황조사 및 학구도 현행화 협조 요청
            </a>
            <a class="list-group-item list-group-item-action py-3" href="#">
              2025년도 초·중등학교 현황조사 및 학구도 현행화 협조 요청
            </a>
            <a class="list-group-item list-group-item-action py-3" href="#">
              2024년도 초·중등학교 현황조사 및 학구도 현행화 협조 요청
            </a>
          </div>
        </div>
      </div>

      <div class="col-xl-6">
        <div class="card border-0 shadow-sm h-100">
          <div class="card-header bg-white d-flex justify-content-between align-items-center">
            <h2 class="h5 text-success fw-bold mb-0">서울 학구 운영 현황</h2>
            <div class="d-flex gap-2">
              <select class="form-select form-select-sm">
                <option>서울</option>
                <option>대전</option>
                <option>충남</option>
              </select>
              <select class="form-select form-select-sm">
                <option>초등학교</option>
                <option>중학교</option>
              </select>
            </div>
          </div>

          <div class="card-body">
            <div class="row align-items-center">
              <div class="col-md-6 text-center">
                <svg width="220" height="220" viewBox="0 0 42 42" class="d-inline-block">
                  <circle cx="21" cy="21" r="15.915" fill="transparent" stroke="#e9ecef" stroke-width="8"></circle>
                  <circle cx="21" cy="21" r="15.915" fill="transparent" stroke="#0d6efd" stroke-width="8" stroke-dasharray="88 12" stroke-dashoffset="25"></circle>
                  <circle cx="21" cy="21" r="15.915" fill="transparent" stroke="#ffc107" stroke-width="8" stroke-dasharray="12 88" stroke-dashoffset="-63"></circle>
                </svg>
              </div>
              <div class="col-md-6">
                <ul class="list-group">
                  <li class="list-group-item d-flex justify-content-between">
                    <span>통학구역</span>
                    <strong>562</strong>
                  </li>
                  <li class="list-group-item d-flex justify-content-between">
                    <span>공동통학구역</span>
                    <strong>67</strong>
                  </li>
                  <li class="list-group-item d-flex justify-content-between">
                    <span>공동(일방)통학구역</span>
                    <strong>0</strong>
                  </li>
                </ul>
              </div>
            </div>
          </div>

          <div class="card-footer bg-white">
            <DataTable
              :columns="['운영현황', '합계', '통학구역', '공동통학구역', '공동(일방)통학구역']"
              :rows="[['초등학교', '629', '562', '67', '0']]"
            />
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import SummaryCard from '../components/common/SummaryCard.vue'
import DataTable from '../components/common/DataTable.vue'
import { dashboardCards } from '../data/sheetData'

const registrationRows = [
  ['제주', '서귀포', '변경', '대정초통학구역', '완료', '04.28'],
  ['인천', '동구', '변경', '인천송현초통학구역', '완료', '04.23'],
  ['경남', '양산', '변경', '물금초통학구역', '완료', '04.17'],
  ['충북', '청주', '변경', '오창초통학구역', '작업', '04.13']
]
</script>
