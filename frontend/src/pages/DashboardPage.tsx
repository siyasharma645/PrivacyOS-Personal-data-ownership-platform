import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'
import {
  Link2, ShieldAlert, Lightbulb, TrendingUp, TrendingDown,
  RefreshCw, ArrowRight, Network, AlertTriangle
} from 'lucide-react'
import {
  AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer
} from 'recharts'
import { dashboardApi } from '@/api'
import { useAuthStore } from '@/store/authStore'
import PrivacyScoreRing from '@/components/dashboard/PrivacyScoreRing'
import RiskBadge from '@/components/ui/RiskBadge'
import { StatCard, PageLoader, ProviderIcon } from '@/components/ui'
import { formatRelativeTime, getRiskBg, getScoreColor } from '@/utils'
import type { DashboardData } from '@/types'
import toast from 'react-hot-toast'

export default function DashboardPage() {
  const user = useAuthStore(s => s.user)
  const { data, isLoading, refetch } = useQuery<DashboardData>({
    queryKey: ['dashboard'],
    queryFn: dashboardApi.get,
  })

  if (isLoading) return <PageLoader />

  const d = data!
  const scoreColor = getScoreColor(d.privacyScore)

  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="page-title">
            Good {getGreeting()}, {user?.fullName?.split(' ')[0] || 'there'} 👋
          </h1>
          <p className="text-zinc-500 text-sm mt-1">Here's your privacy overview</p>
        </div>
        <button onClick={() => { refetch(); toast.success('Dashboard refreshed') }}
          className="btn-secondary">
          <RefreshCw className="w-4 h-4" /> Refresh
        </button>
      </div>

      {/* Score Hero + Stats */}
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-4">
        {/* Score Card */}
        <div className="card p-6 flex items-center gap-6 lg:col-span-1">
          <PrivacyScoreRing score={d.privacyScore} size={110} />
          <div>
            <p className="text-xs text-zinc-500 font-medium uppercase tracking-wider mb-1">Privacy Score</p>
            <RiskBadge level={d.riskLevel} />
            <div className="flex items-center gap-1 mt-2">
              {d.scoreChange >= 0
                ? <TrendingUp className="w-3 h-3 text-emerald-400" />
                : <TrendingDown className="w-3 h-3 text-red-400" />}
              <span className={`text-xs font-medium ${d.scoreChange >= 0 ? 'text-emerald-400' : 'text-red-400'}`}>
                {d.scoreChange >= 0 ? '+' : ''}{d.scoreChange} from last week
              </span>
            </div>
          </div>
        </div>

        {/* Stat Cards */}
        <StatCard
          label="Connected Accounts"
          value={d.connectedAccounts}
          icon={Link2}
          iconColor="text-blue-400"
          subtitle="Active OAuth connections"
        />
        <StatCard
          label="Active Permissions"
          value={d.activePermissions}
          icon={AlertTriangle}
          iconColor="text-amber-400"
          subtitle={`${d.highRiskPermissions} high-risk`}
        />
        <StatCard
          label="Data Breaches"
          value={d.unresolvedBreaches}
          icon={ShieldAlert}
          iconColor={d.unresolvedBreaches > 0 ? 'text-red-400' : 'text-emerald-400'}
          subtitle={d.unresolvedBreaches > 0 ? 'Unresolved – action needed' : 'No active breaches'}
        />
      </div>

      {/* Score Chart + Quick Actions */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        {/* Score History */}
        <div className="card p-5 lg:col-span-2">
          <div className="flex items-center justify-between mb-4">
            <h2 className="font-semibold text-zinc-100">Privacy Score History</h2>
            <span className="text-xs text-zinc-500">Last 30 days</span>
          </div>
          {d.scoreHistory.length > 1 ? (
            <ResponsiveContainer width="100%" height={180}>
              <AreaChart data={d.scoreHistory} margin={{ top: 4, right: 4, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id="scoreGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor={scoreColor} stopOpacity={0.3} />
                    <stop offset="95%" stopColor={scoreColor} stopOpacity={0} />
                  </linearGradient>
                </defs>
                <XAxis dataKey="date" tick={{ fill: '#71717a', fontSize: 11 }} axisLine={false} tickLine={false} />
                <YAxis domain={[0, 100]} tick={{ fill: '#71717a', fontSize: 11 }} axisLine={false} tickLine={false} />
                <Tooltip
                  contentStyle={{ background: '#18181b', border: '1px solid #3f3f46', borderRadius: 8, fontSize: 12 }}
                  labelStyle={{ color: '#a1a1aa' }}
                  itemStyle={{ color: scoreColor }}
                />
                <Area type="monotone" dataKey="score" stroke={scoreColor} strokeWidth={2}
                  fill="url(#scoreGrad)" dot={false} activeDot={{ r: 4, fill: scoreColor }} />
              </AreaChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-[180px] flex items-center justify-center text-zinc-500 text-sm">
              Not enough data yet. Check back after a few days.
            </div>
          )}
        </div>

        {/* Pending Recommendations */}
        <div className="card p-5">
          <div className="flex items-center justify-between mb-4">
            <h2 className="font-semibold text-zinc-100">Top Actions</h2>
            <Link to="/recommendations" className="text-xs text-brand-400 hover:text-brand-300 flex items-center gap-1">
              View all <ArrowRight className="w-3 h-3" />
            </Link>
          </div>
          <div className="space-y-3">
            {d.topRecommendations.length === 0 && (
              <p className="text-xs text-zinc-500 text-center py-4">No pending recommendations 🎉</p>
            )}
            {d.topRecommendations.map(rec => (
              <div key={rec.id} className={`flex items-start gap-3 p-3 rounded-lg border ${getRiskBg(rec.priority)} bg-opacity-10`}>
                <Lightbulb className="w-4 h-4 mt-0.5 shrink-0" />
                <div className="min-w-0">
                  <p className="text-xs font-medium text-zinc-200 truncate">{rec.title}</p>
                  <p className="text-xs text-zinc-500 mt-0.5">+{rec.expectedScoreImprovement} score</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Recent Accounts + Quick Nav */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* Recent Accounts */}
        <div className="card p-5">
          <div className="flex items-center justify-between mb-4">
            <h2 className="font-semibold text-zinc-100">Connected Accounts</h2>
            <Link to="/accounts" className="text-xs text-brand-400 hover:text-brand-300 flex items-center gap-1">
              Manage <ArrowRight className="w-3 h-3" />
            </Link>
          </div>
          <div className="space-y-3">
            {d.recentAccounts.length === 0 && (
              <p className="text-xs text-zinc-500 text-center py-4">No accounts connected yet</p>
            )}
            {d.recentAccounts.map(acc => (
              <div key={acc.id} className="flex items-center gap-3 p-3 rounded-lg bg-surface-800 border border-surface-700">
                <ProviderIcon provider={acc.provider} />
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-zinc-200">{acc.provider}</p>
                  <p className="text-xs text-zinc-500 truncate">{acc.providerEmail}</p>
                </div>
                <div className="text-right shrink-0">
                  <p className="text-xs text-zinc-400">{acc.permissionCount} perms</p>
                  {acc.highRiskCount > 0 && (
                    <p className="text-xs text-orange-400">{acc.highRiskCount} high risk</p>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Quick Links */}
        <div className="card p-5">
          <h2 className="font-semibold text-zinc-100 mb-4">Explore PrivacyOS</h2>
          <div className="grid grid-cols-2 gap-3">
            {[
              { to: '/graph', icon: Network, label: 'Data Graph', desc: 'Visualize connections' },
              { to: '/breaches', icon: ShieldAlert, label: 'Breaches', desc: 'Check exposure' },
              { to: '/timeline', icon: TrendingUp, label: 'Timeline', desc: 'Privacy history' },
              { to: '/ai-assistant', icon: Lightbulb, label: 'AI Assistant', desc: 'Get guidance' },
            ].map(({ to, icon: Icon, label, desc }) => (
              <Link key={to} to={to}
                className="flex flex-col gap-2 p-4 rounded-lg bg-surface-800 border border-surface-700 hover:border-brand-500/50 hover:bg-brand-600/5 transition-all">
                <Icon className="w-5 h-5 text-brand-400" />
                <div>
                  <p className="text-sm font-medium text-zinc-200">{label}</p>
                  <p className="text-xs text-zinc-500">{desc}</p>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}

function getGreeting() {
  const h = new Date().getHours()
  if (h < 12) return 'morning'
  if (h < 17) return 'afternoon'
  return 'evening'
}
