<template>
  <AppLayout>
    <h3 class="fw-bold mb-4">대시보드</h3>
    <div class="row g-3">
      <div class="col-md-4" v-for="card in cards" :key="card.label">
        <div class="card shadow-sm border-0">
          <div class="card-body">
            <div class="text-muted">{{ card.label }}</div>
            <div class="display-6 fw-bold">{{ card.value }}</div>
          </div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>
<script setup>
import { onMounted, ref } from 'vue'
import AppLayout from '../../components/layout/AppLayout.vue'
import { getDashboardSummary } from '../../api/dashboardApi'

const cards = ref([
  { label: '학구 변경 요청', value: 0 },
  { label: '학교현황', value: 0 },
  { label: '공지사항', value: 0 }
])

onMounted(async () => {
  try {
    const res = await getDashboardSummary()
    const data = res.data.data
    cards.value = [
      { label: '학구 변경 요청', value: data.zoneRequestCount },
      { label: '학교현황', value: data.schoolCount },
      { label: '공지사항', value: data.noticeCount }
    ]
  } catch (e) {
    console.warn('대시보드 API 연결 전 기본값 표시')
  }
})
</script>
