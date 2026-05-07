<template>
  <nav class="navbar navbar-expand-lg navbar-dark bg-info shadow-sm">
    <div class="container-fluid px-4">
      <RouterLink class="navbar-brand fw-bold d-flex align-items-center gap-2" to="/">
        <span class="bg-white text-info rounded-circle d-inline-flex align-items-center justify-content-center p-2">
          <i class="bi bi-map"></i>
        </span>
        학구도 관리시스템
      </RouterLink>

      <button
        class="navbar-toggler"
        type="button"
        data-bs-toggle="collapse"
        data-bs-target="#mainNavbar"
        aria-controls="mainNavbar"
        aria-expanded="false"
        aria-label="메뉴 열기"
      >
        <span class="navbar-toggler-icon"></span>
      </button>

      <div id="mainNavbar" class="collapse navbar-collapse">
        <ul class="navbar-nav mx-auto mb-2 mb-lg-0">
          <li class="nav-item">
            <RouterLink class="nav-link fw-semibold" to="/">
              <i class="bi bi-house-door me-1"></i>
              홈
            </RouterLink>
          </li>

          <li v-for="menu in sheetMenus" :key="menu.key" class="nav-item">
            <RouterLink class="nav-link fw-semibold" :to="`/sheet/${menu.key}`">
              <i :class="menu.icon" class="me-1"></i>
              {{ menu.title }}
            </RouterLink>
          </li>
        </ul>

        <div class="dropdown">
          <button class="btn btn-light text-info dropdown-toggle fw-semibold" data-bs-toggle="dropdown">
            <i class="bi bi-person-circle me-1"></i>
            정성범님
          </button>
          <ul class="dropdown-menu dropdown-menu-end">
            <li><span class="dropdown-item-text">학구도관리자</span></li>
            <li><hr class="dropdown-divider" /></li>
            <li><button class="dropdown-item">로그아웃</button></li>
          </ul>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { sheetMenus } from '../../data/sheetData'
</script>
