import { useState } from 'react'
import { Outlet, NavLink, useNavigate } from 'react-router-dom'
import {
  LayoutDashboard, Link2, ShieldAlert, Lightbulb, Clock,
  Network, Bot, Settings, LogOut, Menu, X, Shield,
  ChevronRight, Bell
} from 'lucide-react'
import { useAuthStore } from '@/store/authStore'
import { authApi } from '@/api'
import { cn, getScoreColor } from '@/utils'
import toast from 'react-hot-toast'

const NAV_ITEMS = [
  { to: '/dashboard', icon: LayoutDashboard, label: 'Dashboard' },
  { to: '/accounts', icon: Link2, label: 'Connected Accounts' },
  { to: '/breaches', icon: ShieldAlert, label: 'Breach Monitor' },
  { to: '/recommendations', icon: Lightbulb, label: 'Recommendations' },
  { to: '/timeline', icon: Clock, label: 'Privacy Timeline' },
  { to: '/graph', icon: Network, label: 'Data Graph' },
  { to: '/ai-assistant', icon: Bot, label: 'AI Assistant' },
]

export default function Layout() {
  const [sidebarOpen, setSidebarOpen] = useState(true)
  const { user, logout } = useAuthStore()
  const navigate = useNavigate()

  const handleLogout = async () => {
    try { await authApi.logout() } catch {}
    logout()
    navigate('/login')
    toast.success('Logged out successfully')
  }

  const scoreColor = getScoreColor(user?.privacyScore ?? 50)

  return (
    <div className="flex h-screen bg-surface-950 overflow-hidden">
      {/* Sidebar */}
      <aside className={cn(
        'flex flex-col bg-surface-900 border-r border-surface-800 transition-all duration-300 shrink-0',
        sidebarOpen ? 'w-60' : 'w-16'
      )}>
        {/* Logo */}
        <div className="flex items-center gap-3 px-4 py-5 border-b border-surface-800">
          <div className="w-8 h-8 rounded-lg bg-brand-600 flex items-center justify-center shrink-0">
            <Shield className="w-4 h-4 text-white" />
          </div>
          {sidebarOpen && (
            <span className="font-bold text-zinc-50 text-base tracking-tight">PrivacyOS</span>
          )}
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="ml-auto text-zinc-500 hover:text-zinc-300 transition-colors"
          >
            {sidebarOpen ? <X className="w-4 h-4" /> : <Menu className="w-4 h-4" />}
          </button>
        </div>

        {/* Privacy Score Mini */}
        {sidebarOpen && (
          <div className="mx-3 mt-4 p-3 rounded-lg bg-surface-800 border border-surface-700">
            <div className="flex items-center justify-between mb-2">
              <span className="text-xs text-zinc-500 font-medium">Privacy Score</span>
              <span className="text-xs font-bold" style={{ color: scoreColor }}>
                {user?.riskLevel}
              </span>
            </div>
            <div className="flex items-end gap-2">
              <span className="text-2xl font-bold" style={{ color: scoreColor }}>
                {user?.privacyScore ?? '–'}
              </span>
              <span className="text-zinc-500 text-sm mb-0.5">/100</span>
            </div>
            <div className="mt-2 h-1 bg-surface-700 rounded-full overflow-hidden">
              <div
                className="h-full rounded-full transition-all duration-700"
                style={{ width: `${user?.privacyScore ?? 0}%`, backgroundColor: scoreColor }}
              />
            </div>
          </div>
        )}

        {/* Navigation */}
        <nav className="flex-1 px-2 py-4 space-y-0.5 overflow-y-auto">
          {NAV_ITEMS.map(({ to, icon: Icon, label }) => (
            <NavLink
              key={to}
              to={to}
              className={({ isActive }) => cn(
                'flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-150 group',
                isActive
                  ? 'bg-brand-600/15 text-brand-400 border border-brand-500/20'
                  : 'text-zinc-400 hover:text-zinc-100 hover:bg-surface-800'
              )}
            >
              <Icon className="w-4 h-4 shrink-0" />
              {sidebarOpen && <span className="truncate">{label}</span>}
              {sidebarOpen && (
                <ChevronRight className="w-3 h-3 ml-auto opacity-0 group-hover:opacity-50 transition-opacity" />
              )}
            </NavLink>
          ))}
        </nav>

        {/* Bottom */}
        <div className="p-2 border-t border-surface-800 space-y-0.5">
          <NavLink
            to="/settings"
            className={({ isActive }) => cn(
              'flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-150',
              isActive ? 'bg-surface-800 text-zinc-100' : 'text-zinc-400 hover:text-zinc-100 hover:bg-surface-800'
            )}
          >
            <Settings className="w-4 h-4 shrink-0" />
            {sidebarOpen && <span>Settings</span>}
          </NavLink>
          <button
            onClick={handleLogout}
            className="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-zinc-400 hover:text-red-400 hover:bg-red-500/10 transition-all duration-150"
          >
            <LogOut className="w-4 h-4 shrink-0" />
            {sidebarOpen && <span>Log Out</span>}
          </button>

          {/* User */}
          {sidebarOpen && user && (
            <div className="flex items-center gap-3 px-3 py-2 mt-2">
              <div className="w-7 h-7 rounded-full bg-brand-600 flex items-center justify-center text-xs font-bold text-white shrink-0">
                {user.fullName?.[0]?.toUpperCase() ?? user.email[0].toUpperCase()}
              </div>
              <div className="min-w-0">
                <p className="text-xs font-medium text-zinc-300 truncate">{user.fullName || user.email}</p>
                <p className="text-xs text-zinc-500 truncate">{user.email}</p>
              </div>
            </div>
          )}
        </div>
      </aside>

      {/* Main content */}
      <main className="flex-1 overflow-y-auto">
        {/* Topbar */}
        <div className="sticky top-0 z-10 flex items-center justify-between px-6 py-4 bg-surface-950/80 backdrop-blur border-b border-surface-800">
          <div />
          <div className="flex items-center gap-2">
            <button className="btn-ghost p-2">
              <Bell className="w-4 h-4" />
            </button>
          </div>
        </div>
        <div className="p-6 animate-in">
          <Outlet />
        </div>
      </main>
    </div>
  )
}
