<template>
  <div class="min-vh-100 bg-light">
    <MainNavbar />
    <main>
      <RouterView />
    </main>
    <AppFooter />
  </div>
</template>

<script setup>
import MainNavbar from './components/layout/MainNavbar.vue'
import AppFooter from './components/layout/AppFooter.vue'
</script>
