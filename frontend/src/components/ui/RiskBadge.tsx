import { cn, getRiskBg } from '@/utils'
import type { RiskLevel } from '@/types'

interface Props {
  level: RiskLevel | string
  className?: string
  size?: 'sm' | 'md'
}

const ICONS: Record<string, string> = {
  LOW: '✓',
  MEDIUM: '⚠',
  HIGH: '▲',
  CRITICAL: '✕',
}

export default function RiskBadge({ level, className, size = 'md' }: Props) {
  const upper = level?.toUpperCase() ?? 'LOW'
  return (
    <span className={cn(
      'inline-flex items-center gap-1 rounded-full border font-medium',
      size === 'sm' ? 'px-1.5 py-0.5 text-xs' : 'px-2 py-0.5 text-xs',
      getRiskBg(upper),
      className
    )}>
      <span className="text-xs">{ICONS[upper] ?? '?'}</span>
      {upper}
    </span>
  )
}
