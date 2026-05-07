<template>
  <div class="card border-0 shadow-sm h-100">
    <div class="card-body">
      <div class="d-flex justify-content-between align-items-start">
        <div>
          <p class="text-muted mb-1">{{ title }}</p>
          <h3 class="fw-bold mb-0">{{ value }}</h3>
        </div>
        <span :class="`text-bg-${tone}`" class="badge rounded-pill fs-6 p-3">
          <i :class="icon"></i>
        </span>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  title: { type: String, required: true },
  value: { type: String, required: true },
  icon: { type: String, required: true },
  tone: { type: String, default: 'primary' }
})
</script>
