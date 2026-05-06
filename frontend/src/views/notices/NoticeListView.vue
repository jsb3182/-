<template>
  <AppLayout>
    <h3 class="fw-bold mb-3">공지사항</h3>
    <div class="list-group">
      <div class="list-group-item" v-for="n in rows" :key="n.noticeId">
        <div class="fw-bold">{{ n.fixedYn === 'Y' ? '[고정] ' : '' }}{{ n.title }}</div>
        <div class="text-muted small">{{ n.writerName }} · 조회 {{ n.viewCount }}</div>
      </div>
    </div>
  </AppLayout>
</template>
<script setup>
import { onMounted, ref } from 'vue'
import AppLayout from '../../components/layout/AppLayout.vue'
import { getNotices } from '../../api/noticeApi'
const rows = ref([])
onMounted(async () => { rows.value = (await getNotices({ page: 0, size: 20 })).data.data.content || [] })
</script>
