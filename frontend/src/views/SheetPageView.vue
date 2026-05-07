<template>
  <section class="container-fluid px-4 py-4">
    <div class="card border-0 shadow-sm mb-4">
      <div class="card-body p-4">
        <div class="row align-items-center g-3">
          <div class="col-lg-8">
            <div class="d-flex align-items-center gap-3">
              <span class="badge text-bg-info rounded-pill fs-5 p-3">
                <i :class="sheet.icon"></i>
              </span>
              <div>
                <h1 class="h3 fw-bold mb-1">{{ sheet.title }}</h1>
                <p class="text-muted mb-0">{{ sheet.description }}</p>
              </div>
            </div>
          </div>

          <div class="col-lg-4">
            <div class="input-group">
              <input v-model="keyword" class="form-control" placeholder="검색어를 입력해 주세요." />
              <button class="btn btn-success">
                <i class="bi bi-search me-1"></i>
                검색
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="row g-4 mb-4">
      <div class="col-md-3">
        <SummaryCard title="전체" value="286" icon="bi-collection" tone="primary" />
      </div>
      <div class="col-md-3">
        <SummaryCard title="신규" value="16" icon="bi-plus-circle" tone="success" />
      </div>
      <div class="col-md-3">
        <SummaryCard title="변경" value="22" icon="bi-arrow-repeat" tone="warning" />
      </div>
      <div class="col-md-3">
        <SummaryCard title="비활성" value="3" icon="bi-archive" tone="secondary" />
      </div>
    </div>

    <div class="card border-0 shadow-sm">
      <div class="card-header bg-white d-flex flex-wrap justify-content-between align-items-center gap-2">
        <h2 class="h5 mb-0 fw-bold text-success">{{ sheet.title }} 목록</h2>
        <div class="d-flex flex-wrap gap-2">
          <button class="btn btn-outline-secondary btn-sm">
            <i class="bi bi-upload me-1"></i>
            엑셀 업로드
          </button>
          <button class="btn btn-outline-success btn-sm">
            <i class="bi bi-download me-1"></i>
            다운로드
          </button>
          <button class="btn btn-primary btn-sm">
            <i class="bi bi-plus-lg me-1"></i>
            신규 등록
          </button>
        </div>
      </div>

      <div class="card-body p-0">
        <DataTable :columns="sheet.columns" :rows="filteredRows" />
      </div>

      <div class="card-footer bg-white d-flex justify-content-between align-items-center">
        <span class="text-muted small">
          총 {{ filteredRows.length }}건 표시
        </span>
        <nav aria-label="페이지 이동">
          <ul class="pagination pagination-sm mb-0">
            <li class="page-item disabled">
              <span class="page-link">이전</span>
            </li>
            <li class="page-item active">
              <span class="page-link">1</span>
            </li>
            <li class="page-item">
              <button class="page-link">다음</button>
            </li>
          </ul>
        </nav>
      </div>
    </div>

    <div class="alert alert-info mt-4 mb-0">
      <i class="bi bi-info-circle me-1"></i>
      이 화면은 첨부된 엑셀의 <strong>{{ sheet.title }}</strong> 시트를 하나의 Vue 페이지 기능으로 매핑한 구조입니다.
      실제 데이터는 Python 동기화 후 API로 연결하면 됩니다.
    </div>
  </section>
</template>

<script setup>
import { computed, ref } from 'vue'
import { sheetMenus } from '../data/sheetData'
import SummaryCard from '../components/common/SummaryCard.vue'
import DataTable from '../components/common/DataTable.vue'

const props = defineProps({
  sheetKey: {
    type: String,
    required: true
  }
})

const keyword = ref('')

const sheet = computed(() => {
  return sheetMenus.find((item) => item.key === props.sheetKey) || sheetMenus[0]
})

const filteredRows = computed(() => {
  if (!keyword.value) {
    return sheet.value.rows
  }

  const target = keyword.value.toLowerCase()
  return sheet.value.rows.filter((row) => {
    return row.some((cell) => String(cell).toLowerCase().includes(target))
  })
})
</script>
