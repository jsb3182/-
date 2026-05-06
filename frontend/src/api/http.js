import axios from 'axios'

const http = axios.create({
  baseURL: '/api',
  timeout: 10000
})

http.interceptors.response.use(
  response => response,
  error => {
    console.error('API 오류:', error)
    return Promise.reject(error)
  }
)

export default http
