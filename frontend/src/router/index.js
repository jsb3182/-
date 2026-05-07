import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import SheetPageView from '../views/SheetPageView.vue'

const routes = [
  {
    path: '/',
    name: 'home',
    component: HomeView
  },
  {
    path: '/sheet/:sheetKey',
    name: 'sheet',
    component: SheetPageView,
    props: true
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
