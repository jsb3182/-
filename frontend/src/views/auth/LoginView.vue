<template>
  <div class="d-flex align-items-center justify-content-center vh-100 bg-light">
    <div class="card shadow-sm" style="width: 420px;">
      <div class="card-body p-4">
        <h4 class="fw-bold mb-3">학구도 자동 관리시스템</h4>
        <input v-model="loginId" class="form-control mb-2" placeholder="아이디" />
        <input v-model="password" type="password" class="form-control mb-3" placeholder="비밀번호" />
        <button class="btn btn-primary w-100" @click="login">로그인</button>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
const router = useRouter()
const loginId = ref('')
const password = ref('')
const login = () => {
  // 1차 MVP에서는 화면 이동만 처리합니다. 실제 인증은 authApi와 Pinia store로 연결하세요.
  router.push('/dashboard')
}
</script>
