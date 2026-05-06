<template>
  <AppLayout>
    <div class="d-flex justify-content-between align-items-center mb-3">
      <h3 class="fw-bold">학구 변경 요청 관리</h3>
      <button class="btn btn-success">엑셀 업로드</button>
    </div>
    <div class="card shadow-sm border-0">
      <div class="card-body">
        <table class="table table-hover align-middle">
          <thead>
            <tr>
              <th>ID</th><th>학구명</th><th>교육청</th><th>학교급</th><th>진행상태</th><th>작업자</th><th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in rows" :key="item.requestId">
              <td>{{ item.requestId }}</td>
              <td>{{ item.zoneName }}</td>
              <td>{{ item.educationOffice }}</td>
              <td>{{ item.schoolLevel }}</td>
              <td><StatusBadge :status="item.progressStatus" /></td>
              <td>{{ item.workerName }}</td>
              <td><router-link class="btn btn-sm btn-outline-primary" :to="`/zone-requests/${item.requestId}`">상세</router-link></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </AppLayout>
</template>
<script setup>
import { onMounted, ref } from 'vue'
import AppLayout from '../../components/layout/AppLayout.vue'
import StatusBadge from '../../components/common/StatusBadge.vue'
import { getZoneRequests } from '../../api/zoneRequestApi'
const rows = ref([])
onMounted(async () => {
  const res = await getZoneRequests({ page: 0, size: 20 })
  rows.value = res.data.data.content || []
})
</script>
