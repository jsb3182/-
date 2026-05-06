import http from './http'
export const getSchools = (params) => http.get('/schools', { params })
