import { createRouter, createWebHistory } from 'vue-router'
import LoginView from '../views/auth/LoginView.vue'
import DashboardView from '../views/dashboard/DashboardView.vue'
import ZoneRequestListView from '../views/requests/ZoneRequestListView.vue'
import ZoneRequestDetailView from '../views/requests/ZoneRequestDetailView.vue'
import SchoolListView from '../views/schools/SchoolListView.vue'
import NoticeListView from '../views/notices/NoticeListView.vue'

const routes = [
  { path: '/', redirect: '/dashboard' },
  { path: '/login', component: LoginView },
  { path: '/dashboard', component: DashboardView },
  { path: '/zone-requests', component: ZoneRequestListView },
  { path: '/zone-requests/:id', component: ZoneRequestDetailView },
  { path: '/schools', component: SchoolListView },
  { path: '/notices', component: NoticeListView }
]

export default createRouter({ history: createWebHistory(), routes })
