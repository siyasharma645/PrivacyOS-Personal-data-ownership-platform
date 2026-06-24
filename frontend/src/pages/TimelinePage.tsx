import { useState } from 'react'
import { useInfiniteQuery } from '@tanstack/react-query'
import { Clock, ChevronDown, TrendingUp, TrendingDown, Minus } from 'lucide-react'
import { timelineApi } from '@/api'
import { SectionHeader, PageLoader, EmptyState } from '@/components/ui'
import { formatRelativeTime } from '@/utils'
import type { PrivacyEvent } from '@/types'

const EVENT_ICONS: Record<string, string> = {
  ACCOUNT_CONNECTED: '🔗',
  ACCOUNT_DISCONNECTED: '🔌',
  PERMISSION_GRANTED: '✅',
  PERMISSION_REVOKED: '❌',
  BREACH_DETECTED: '🚨',
  BREACH_REMEDIATED: '🛡️',
  SCORE_CHANGED: '📊',
  PERMISSION_RISK: '⚠️',
}

const SEVERITY_STYLES: Record<string, string> = {
  INFO: 'border-l-blue-500 bg-blue-500/5',
  WARNING: 'border-l-amber-500 bg-amber-500/5',
  CRITICAL: 'border-l-red-500 bg-red-500/5',
}

export default function TimelinePage() {
  const [filter, setFilter] = useState<string>('ALL')

  const { data, fetchNextPage, hasNextPage, isFetchingNextPage, isLoading } = useInfiniteQuery({
    queryKey: ['timeline'],
    queryFn: ({ pageParam = 0 }) => timelineApi.get(pageParam as number, 20),
    initialPageParam: 0,
    getNextPageParam: (last: any) =>
      last.number < last.totalPages - 1 ? last.number + 1 : undefined,
  })

  const allEvents: PrivacyEvent[] = data?.pages.flatMap((p: any) => p.content) ?? []
  const filtered = filter === 'ALL' ? allEvents : allEvents.filter(e => e.severity === filter)

  if (isLoading) return <PageLoader />

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <SectionHeader
        title="Privacy Timeline"
        subtitle="A complete audit log of your privacy events and changes"
      />

      {/* Filters */}
      <div className="flex gap-2">
        {['ALL', 'INFO', 'WARNING', 'CRITICAL'].map(f => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-all ${
              filter === f
                ? 'bg-brand-600 text-white'
                : 'bg-surface-800 text-zinc-400 hover:text-zinc-100 border border-surface-700'
            }`}
          >
            {f}
          </button>
        ))}
      </div>

      {filtered.length === 0 && (
        <EmptyState icon={Clock} title="No events yet" description="Privacy events will appear here as you connect accounts and changes are detected." />
      )}

      {/* Timeline */}
      <div className="relative">
        {/* Vertical line */}
        <div className="absolute left-[19px] top-0 bottom-0 w-0.5 bg-surface-800" />

        <div className="space-y-3">
          {filtered.map((event, i) => (
            <div key={event.id} className="flex gap-4 relative">
              {/* Dot */}
              <div className={`w-10 h-10 rounded-full flex items-center justify-center text-sm shrink-0 z-10 border-2 ${
                event.severity === 'CRITICAL' ? 'bg-red-500/20 border-red-500/50' :
                event.severity === 'WARNING' ? 'bg-amber-500/20 border-amber-500/50' :
                'bg-blue-500/20 border-blue-500/50'
              }`}>
                {EVENT_ICONS[event.eventType] ?? '📋'}
              </div>

              {/* Card */}
              <div className={`flex-1 card border-l-2 p-4 mb-0 ${SEVERITY_STYLES[event.severity] ?? 'border-l-zinc-700'}`}>
                <div className="flex items-start justify-between gap-2">
                  <div className="flex-1">
                    <h3 className="text-sm font-semibold text-zinc-100">{event.title}</h3>
                    <p className="text-xs text-zinc-400 mt-0.5">{event.description}</p>
                  </div>
                  <span className="text-xs text-zinc-600 shrink-0 whitespace-nowrap">
                    {formatRelativeTime(event.createdAt)}
                  </span>
                </div>

                {/* Score change */}
                {event.scoreBefore != null && event.scoreAfter != null && (
                  <div className="flex items-center gap-2 mt-2">
                    <span className="text-xs text-zinc-500">Score:</span>
                    <span className="text-xs font-medium text-zinc-300">{event.scoreBefore}</span>
                    {event.scoreAfter > event.scoreBefore
                      ? <TrendingUp className="w-3 h-3 text-emerald-400" />
                      : event.scoreAfter < event.scoreBefore
                        ? <TrendingDown className="w-3 h-3 text-red-400" />
                        : <Minus className="w-3 h-3 text-zinc-500" />}
                    <span className={`text-xs font-medium ${
                      event.scoreAfter > event.scoreBefore ? 'text-emerald-400' :
                      event.scoreAfter < event.scoreBefore ? 'text-red-400' : 'text-zinc-500'
                    }`}>{event.scoreAfter}</span>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Load more */}
      {hasNextPage && (
        <div className="text-center">
          <button
            onClick={() => fetchNextPage()}
            disabled={isFetchingNextPage}
            className="btn-secondary mx-auto"
          >
            <ChevronDown className={`w-4 h-4 ${isFetchingNextPage ? 'animate-bounce' : ''}`} />
            {isFetchingNextPage ? 'Loading...' : 'Load more'}
          </button>
        </div>
      )}
    </div>
  )
}
