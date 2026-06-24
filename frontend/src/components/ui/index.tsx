import { cn } from '@/utils'
import type { LucideIcon } from 'lucide-react'
import { Loader2 } from 'lucide-react'

// ── StatCard ─────────────────────────────────────────────
interface StatCardProps {
  label: string
  value: string | number
  icon: LucideIcon
  iconColor?: string
  change?: number
  subtitle?: string
  className?: string
}

export function StatCard({ label, value, icon: Icon, iconColor = 'text-brand-400', change, subtitle, className }: StatCardProps) {
  return (
    <div className={cn('stat-card', className)}>
      <div className="flex items-center justify-between">
        <span className="section-title">{label}</span>
        <div className={cn('w-8 h-8 rounded-lg bg-surface-800 flex items-center justify-center', iconColor)}>
          <Icon className="w-4 h-4" />
        </div>
      </div>
      <div className="flex items-end gap-2">
        <span className="text-2xl font-bold text-zinc-50">{value}</span>
        {change !== undefined && (
          <span className={cn('text-xs font-medium mb-0.5', change >= 0 ? 'text-emerald-400' : 'text-red-400')}>
            {change >= 0 ? '+' : ''}{change}
          </span>
        )}
      </div>
      {subtitle && <p className="text-xs text-zinc-500">{subtitle}</p>}
    </div>
  )
}

// ── LoadingSpinner ────────────────────────────────────────
export function LoadingSpinner({ className }: { className?: string }) {
  return (
    <div className={cn('flex items-center justify-center', className)}>
      <Loader2 className="w-6 h-6 text-brand-400 animate-spin" />
    </div>
  )
}

// ── PageLoader ────────────────────────────────────────────
export function PageLoader() {
  return (
    <div className="flex items-center justify-center h-64">
      <div className="flex flex-col items-center gap-3">
        <Loader2 className="w-8 h-8 text-brand-400 animate-spin" />
        <p className="text-sm text-zinc-500">Loading...</p>
      </div>
    </div>
  )
}

// ── EmptyState ────────────────────────────────────────────
interface EmptyStateProps {
  icon: LucideIcon
  title: string
  description?: string
  action?: React.ReactNode
}
export function EmptyState({ icon: Icon, title, description, action }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center py-16 gap-3">
      <div className="w-12 h-12 rounded-full bg-surface-800 flex items-center justify-center">
        <Icon className="w-6 h-6 text-zinc-500" />
      </div>
      <p className="text-sm font-medium text-zinc-300">{title}</p>
      {description && <p className="text-xs text-zinc-500 text-center max-w-xs">{description}</p>}
      {action && <div className="mt-2">{action}</div>}
    </div>
  )
}

// ── SectionHeader ─────────────────────────────────────────
interface SectionHeaderProps {
  title: string
  subtitle?: string
  action?: React.ReactNode
}
export function SectionHeader({ title, subtitle, action }: SectionHeaderProps) {
  return (
    <div className="flex items-start justify-between mb-6">
      <div>
        <h1 className="page-title">{title}</h1>
        {subtitle && <p className="text-sm text-zinc-500 mt-1">{subtitle}</p>}
      </div>
      {action && <div>{action}</div>}
    </div>
  )
}

// ── ProviderIcon ─────────────────────────────────────────
export function ProviderIcon({ provider, size = 'md' }: { provider: string; size?: 'sm' | 'md' | 'lg' }) {
  const colors: Record<string, string> = {
    GOOGLE: '#4285f4', GITHUB: '#6e40c9', LINKEDIN: '#0a66c2',
    FACEBOOK: '#1877f2', TWITTER: '#1da1f2', MICROSOFT: '#00a4ef',
  }
  const icons: Record<string, string> = {
    GOOGLE: 'G', GITHUB: 'GH', LINKEDIN: 'in', FACEBOOK: 'f', TWITTER: '𝕏', MICROSOFT: 'M',
  }
  const upper = provider.toUpperCase()
  const sizes = { sm: 'w-6 h-6 text-xs', md: 'w-8 h-8 text-xs', lg: 'w-10 h-10 text-sm' }

  return (
    <div
      className={cn('rounded-lg flex items-center justify-center font-bold text-white', sizes[size])}
      style={{ backgroundColor: colors[upper] ?? '#6366f1' }}
    >
      {icons[upper] ?? provider[0]}
    </div>
  )
}
