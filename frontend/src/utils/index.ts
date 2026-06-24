import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'
import type { RiskLevel } from '@/types'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function getRiskColor(level: RiskLevel | string) {
  switch (level) {
    case 'LOW': return 'text-emerald-400'
    case 'MEDIUM': return 'text-amber-400'
    case 'HIGH': return 'text-orange-400'
    case 'CRITICAL': return 'text-red-400'
    default: return 'text-zinc-400'
  }
}

export function getRiskBg(level: RiskLevel | string) {
  switch (level) {
    case 'LOW': return 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20'
    case 'MEDIUM': return 'bg-amber-500/10 text-amber-400 border-amber-500/20'
    case 'HIGH': return 'bg-orange-500/10 text-orange-400 border-orange-500/20'
    case 'CRITICAL': return 'bg-red-500/10 text-red-400 border-red-500/20'
    default: return 'bg-zinc-500/10 text-zinc-400 border-zinc-500/20'
  }
}

export function getScoreColor(score: number): string {
  if (score >= 80) return '#22c55e'
  if (score >= 60) return '#f59e0b'
  if (score >= 40) return '#f97316'
  return '#ef4444'
}

export function getScoreLabel(score: number): string {
  if (score >= 80) return 'Good'
  if (score >= 60) return 'Fair'
  if (score >= 40) return 'Poor'
  return 'Critical'
}

export function getSeverityIcon(severity: string): string {
  switch (severity) {
    case 'CRITICAL': return '🔴'
    case 'WARNING': return '🟡'
    default: return '🔵'
  }
}

export function getProviderColor(provider: string): string {
  switch (provider.toUpperCase()) {
    case 'GOOGLE': return '#4285f4'
    case 'GITHUB': return '#6e40c9'
    case 'LINKEDIN': return '#0a66c2'
    case 'FACEBOOK': return '#1877f2'
    case 'TWITTER': return '#1da1f2'
    case 'MICROSOFT': return '#00a4ef'
    default: return '#6366f1'
  }
}

export function getProviderIcon(provider: string): string {
  switch (provider.toUpperCase()) {
    case 'GOOGLE': return 'G'
    case 'GITHUB': return '⌥'
    case 'LINKEDIN': return 'in'
    case 'FACEBOOK': return 'f'
    case 'TWITTER': return '𝕏'
    case 'MICROSOFT': return 'M'
    default: return '?'
  }
}

export function formatDate(date: string | Date): string {
  return new Intl.DateTimeFormat('en-US', {
    month: 'short', day: 'numeric', year: 'numeric'
  }).format(new Date(date))
}

export function formatRelativeTime(date: string | Date): string {
  const d = new Date(date)
  const now = new Date()
  const diff = now.getTime() - d.getTime()
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)
  if (minutes < 1) return 'Just now'
  if (minutes < 60) return `${minutes}m ago`
  if (hours < 24) return `${hours}h ago`
  if (days < 7) return `${days}d ago`
  return formatDate(date)
}

export function formatNumber(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`
  if (n >= 1_000) return `${(n / 1_000).toFixed(1)}K`
  return n.toString()
}

export function truncate(str: string, maxLen: number): string {
  if (str.length <= maxLen) return str
  return str.slice(0, maxLen) + '…'
}
