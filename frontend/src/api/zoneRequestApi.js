import http from './http'
export const getZoneRequests = (params) => http.get('/zone-requests', { params })
export const getZoneRequest = (id) => http.get(`/zone-requests/${id}`)
export const saveZoneRequest = (data) => http.post('/zone-requests', data)
export const changeZoneRequestStatus = (id, data) => http.patch(`/zone-requests/${id}/status`, data)
