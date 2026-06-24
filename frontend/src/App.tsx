import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { useAuthStore } from '@/store/authStore'
import Layout from '@/components/layout/Layout'
import LoginPage from '@/pages/LoginPage'
import RegisterPage from '@/pages/RegisterPage'
import DashboardPage from '@/pages/DashboardPage'
import AccountsPage from '@/pages/AccountsPage'
import BreachesPage from '@/pages/BreachesPage'
import RecommendationsPage from '@/pages/RecommendationsPage'
import TimelinePage from '@/pages/TimelinePage'
import GraphPage from '@/pages/GraphPage'
import AiAssistantPage from '@/pages/AiAssistantPage'
import SettingsPage from '@/pages/SettingsPage'

function PrivateRoute({ children }: { children: React.ReactNode }) {
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated)
  return isAuthenticated ? <>{children}</> : <Navigate to="/login" replace />
}

function PublicRoute({ children }: { children: React.ReactNode }) {
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated)
  return !isAuthenticated ? <>{children}</> : <Navigate to="/dashboard" replace />
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        <Route path="/login" element={<PublicRoute><LoginPage /></PublicRoute>} />
        <Route path="/register" element={<PublicRoute><RegisterPage /></PublicRoute>} />
        <Route
          path="/"
          element={<PrivateRoute><Layout /></PrivateRoute>}
        >
          <Route path="dashboard" element={<DashboardPage />} />
          <Route path="accounts" element={<AccountsPage />} />
          <Route path="breaches" element={<BreachesPage />} />
          <Route path="recommendations" element={<RecommendationsPage />} />
          <Route path="timeline" element={<TimelinePage />} />
          <Route path="graph" element={<GraphPage />} />
          <Route path="ai-assistant" element={<AiAssistantPage />} />
          <Route path="settings" element={<SettingsPage />} />
        </Route>
        <Route path="*" element={<Navigate to="/dashboard" replace />} />
      </Routes>
    </BrowserRouter>
  )
}
