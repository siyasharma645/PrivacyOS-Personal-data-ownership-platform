import { useEffect, useRef } from 'react'
import { getScoreColor, getScoreLabel } from '@/utils'
import { cn } from '@/utils'

interface Props {
  score: number
  size?: number
  strokeWidth?: number
  showLabel?: boolean
  className?: string
  animate?: boolean
}

export default function PrivacyScoreRing({
  score,
  size = 120,
  strokeWidth = 10,
  showLabel = true,
  className,
  animate = true,
}: Props) {
  const circleRef = useRef<SVGCircleElement>(null)
  const r = (size - strokeWidth) / 2
  const circ = 2 * Math.PI * r
  const offset = circ - (score / 100) * circ
  const color = getScoreColor(score)

  useEffect(() => {
    if (!circleRef.current || !animate) return
    const el = circleRef.current
    el.style.strokeDashoffset = String(circ)
    requestAnimationFrame(() => {
      el.style.transition = 'stroke-dashoffset 1.2s cubic-bezier(0.4, 0, 0.2, 1)'
      el.style.strokeDashoffset = String(offset)
    })
  }, [score, circ, offset, animate])

  return (
    <div className={cn('relative inline-flex items-center justify-center', className)}>
      <svg width={size} height={size} className="-rotate-90">
        {/* Track */}
        <circle
          cx={size / 2}
          cy={size / 2}
          r={r}
          fill="none"
          stroke="#27272a"
          strokeWidth={strokeWidth}
        />
        {/* Progress */}
        <circle
          ref={circleRef}
          cx={size / 2}
          cy={size / 2}
          r={r}
          fill="none"
          stroke={color}
          strokeWidth={strokeWidth}
          strokeLinecap="round"
          strokeDasharray={circ}
          strokeDashoffset={animate ? circ : offset}
          style={{ filter: `drop-shadow(0 0 6px ${color}66)` }}
        />
      </svg>
      {showLabel && (
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <span className="text-2xl font-bold" style={{ color }}>{score}</span>
          <span className="text-xs text-zinc-500 font-medium">{getScoreLabel(score)}</span>
        </div>
      )}
    </div>
  )
}
