<template>
  <AppLayout>
    <h3 class="fw-bold mb-3">학구 변경 요청 상세</h3>
    <div class="card shadow-sm border-0" v-if="item">
      <div class="card-body">
        <h5>{{ item.zoneName }}</h5>
        <p class="text-muted">{{ item.requestContent }}</p>
        <div class="row g-2 mb-3">
          <div class="col-md-3"><b>진행상태</b><br><StatusBadge :status="item.progressStatus" /></div>
          <div class="col-md-3"><b>교육청</b><br>{{ item.educationOffice }}</div>
          <div class="col-md-3"><b>지원청</b><br>{{ item.supportOffice }}</div>
          <div class="col-md-3"><b>담당자</b><br>{{ item.managerName }}</div>
        </div>
        <select v-model="afterStatus" class="form-select w-auto d-inline-block me-2">
          <option>등록</option><option>접수</option><option>작업</option><option>검토</option><option>적용</option><option>완료</option><option>취소</option><option>재요청</option>
        </select>
        <button class="btn btn-primary" @click="changeStatus">상태 변경</button>
      </div>
    </div>
  </AppLayout>
</template>
<script setup>
import { onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import AppLayout from '../../components/layout/AppLayout.vue'
import StatusBadge from '../../components/common/StatusBadge.vue'
import { getZoneRequest, changeZoneRequestStatus } from '../../api/zoneRequestApi'
const route = useRoute()
const item = ref(null)
const afterStatus = ref('접수')
const load = async () => { item.value = (await getZoneRequest(route.params.id)).data.data }
const changeStatus = async () => {
  await changeZoneRequestStatus(route.params.id, { afterStatus: afterStatus.value, changedByName: '정성범', changeReason: '화면에서 상태 변경' })
  await load()
}
onMounted(load)
</script>
