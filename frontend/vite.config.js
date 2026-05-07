import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// Vue + Vite 개발 서버 설정입니다.
// /api 요청은 나중에 Spring Boot 또는 Python API 서버로 프록시할 수 있습니다.
export default defineConfig({
  plugins: [vue()],
  server: {
    host: '0.0.0.0',
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:8081',
        changeOrigin: true
      }
    }
  }
})
