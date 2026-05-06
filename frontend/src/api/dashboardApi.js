import http from './http'
export const getDashboardSummary = () => http.get('/dashboard/summary')
