<template>
  <div>
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary px-4">
      <router-link class="navbar-brand fw-bold" to="/dashboard">학구도 자동 관리시스템</router-link>
      <div class="navbar-nav">
        <router-link class="nav-link" to="/dashboard">대시보드</router-link>
        <router-link class="nav-link" to="/zone-requests">학구 변경 관리</router-link>
        <router-link class="nav-link" to="/schools">학교현황</router-link>
        <router-link class="nav-link" to="/notices">공지사항</router-link>
      </div>
    </nav>
    <main class="container-fluid p-4 bg-light min-vh-100">
      <slot />
    </main>
  </div>
</template>
