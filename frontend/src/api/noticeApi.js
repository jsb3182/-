import http from './http'
export const getNotices = (params) => http.get('/notices', { params })
