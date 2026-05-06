<template>
  <AppLayout>
    <h3 class="fw-bold mb-3">학교현황</h3>
    <div class="card shadow-sm border-0">
      <div class="card-body">
        <table class="table table-hover">
          <thead><tr><th>ID</th><th>학교명</th><th>학교급</th><th>교육청</th><th>EPSG:5186 X</th><th>EPSG:5186 Y</th></tr></thead>
          <tbody>
            <tr v-for="s in rows" :key="s.schoolId">
              <td>{{ s.schoolId }}</td><td>{{ s.schoolName }}</td><td>{{ s.schoolLevel }}</td><td>{{ s.educationOffice }}</td><td>{{ s.xCoord }}</td><td>{{ s.yCoord }}</td>
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
import { getSchools } from '../../api/schoolApi'
const rows = ref([])
onMounted(async () => { rows.value = (await getSchools({ page: 0, size: 20 })).data.data.content || [] })
</script>
