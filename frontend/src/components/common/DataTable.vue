<template>
  <div class="table-responsive">
    <table class="table table-hover table-bordered align-middle mb-0">
      <thead class="table-success">
        <tr>
          <th v-for="column in columns" :key="column" class="text-center text-nowrap">
            {{ column }}
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(row, rowIndex) in rows" :key="rowIndex">
          <td v-for="(cell, cellIndex) in row" :key="`${rowIndex}-${cellIndex}`" class="text-center text-nowrap">
            <span
              v-if="String(cell).includes('완료')"
              class="badge text-bg-success"
            >
              {{ cell }}
            </span>
            <span
              v-else-if="String(cell).includes('작업')"
              class="badge text-bg-warning"
            >
              {{ cell }}
            </span>
            <span
              v-else-if="String(cell).includes('검토')"
              class="badge text-bg-info"
            >
              {{ cell }}
            </span>
            <span v-else>
              {{ cell }}
            </span>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
defineProps({
  columns: { type: Array, required: true },
  rows: { type: Array, required: true }
})
</script>
