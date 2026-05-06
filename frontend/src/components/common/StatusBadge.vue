<template>
  <span class="badge" :class="badgeClass">{{ status }}</span>
</template>
<script setup>
const props = defineProps({ status: String })
const badgeClass = {
  '등록': 'text-bg-secondary',
  '접수': 'text-bg-info',
  '작업': 'text-bg-warning',
  '검토': 'text-bg-primary',
  '적용': 'text-bg-dark',
  '완료': 'text-bg-success',
  '취소': 'text-bg-danger',
  '재요청': 'text-bg-danger'
}[props.status] || 'text-bg-secondary'
</script>
