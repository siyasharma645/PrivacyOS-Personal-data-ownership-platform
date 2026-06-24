import axios from 'axios'
import { useAuthStore } from '@/store/authStore'

const BASE_URL = (import.meta as any).env?.VITE_API_URL || ''

export const api = axios.create({
  baseURL: `${BASE_URL}/api/v1`,
  headers: { 'Content-Type': 'application/json' },
  timeout: 15000,
})

// Request interceptor – attach JWT
api.interceptors.request.use((config) => {
  const token = useAuthStore.getState().accessToken
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// Response interceptor – refresh on 401
api.interceptors.response.use(
  (res) => res,
  async (error) => {
    const original = error.config
    if (error.response?.status === 401 && !original._retry) {
      original._retry = true
      try {
        const refreshToken = useAuthStore.getState().refreshToken
        if (!refreshToken) throw new Error('No refresh token')
        const { data } = await axios.post(`${BASE_URL}/api/v1/auth/refresh`, { refreshToken })
        useAuthStore.getState().setTokens(data.accessToken, data.refreshToken)
        original.headers.Authorization = `Bearer ${data.accessToken}`
        return api(original)
      } catch {
        useAuthStore.getState().logout()
        window.location.href = '/login'
      }
    }
    return Promise.reject(error)
  }
)

// ── Auth ──────────────────────────────────────────────────
export const authApi = {
  register: (data: { email: string; password: string; fullName: string }) =>
    api.post('/auth/register', data).then(r => r.data),
  login: (data: { email: string; password: string }) =>
    api.post('/auth/login', data).then(r => r.data),
  logout: () => api.post('/auth/logout'),
  me: () => api.get('/auth/me').then(r => r.data),
}

// ── Dashboard ─────────────────────────────────────────────
export const dashboardApi = {
  get: () => api.get('/dashboard').then(r => r.data),
  getScore: () => api.get('/dashboard/score').then(r => r.data),
  recalculate: () => api.post('/dashboard/score/recalculate').then(r => r.data),
}

// ── Accounts ─────────────────────────────────────────────
export const accountsApi = {
  list: () => api.get('/accounts').then(r => r.data),
  get: (id: string) => api.get(`/accounts/${id}`).then(r => r.data),
  disconnect: (id: string) => api.delete(`/accounts/${id}`),
  sync: (id: string) => api.post(`/accounts/${id}/sync`).then(r => r.data),
  getPermissions: (id: string) => api.get(`/accounts/${id}/permissions`).then(r => r.data),
  revokePermission: (permId: string) => api.delete(`/accounts/permissions/${permId}`),
}

// ── Breaches ─────────────────────────────────────────────
export const breachApi = {
  list: () => api.get('/breaches').then(r => r.data),
  check: () => api.post('/breaches/check').then(r => r.data),
  remediate: (id: string) => api.post(`/breaches/${id}/remediate`).then(r => r.data),
}

// ── Recommendations ───────────────────────────────────────
export const recommendationApi = {
  list: () => api.get('/recommendations').then(r => r.data),
  complete: (id: string) => api.post(`/recommendations/${id}/complete`).then(r => r.data),
  dismiss: (id: string) => api.post(`/recommendations/${id}/dismiss`).then(r => r.data),
  generate: () => api.post('/recommendations/generate'),
}

// ── Timeline ─────────────────────────────────────────────
export const timelineApi = {
  get: (page = 0, size = 20) =>
    api.get('/timeline', { params: { page, size } }).then(r => r.data),
}

// ── Graph ─────────────────────────────────────────────────
export const graphApi = {
  get: () => api.get('/graph').then(r => r.data),
}

// ── AI ────────────────────────────────────────────────────
export const aiApi = {
  chat: (message: string, history: { role: string; content: string }[]) =>
    api.post('/ai/chat', { message, history }).then(r => r.data),
  explainPermission: (id: string) =>
    api.post(`/ai/explain/permission/${id}`).then(r => r.data),
}
