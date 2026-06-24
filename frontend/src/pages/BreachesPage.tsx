import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { ShieldAlert, Search, CheckCircle, AlertTriangle, RefreshCw, Calendar, Users } from 'lucide-react'
import { breachApi } from '@/api'
import { SectionHeader, PageLoader, EmptyState } from '@/components/ui'
import { formatDate, formatNumber } from '@/utils'
import type { BreachRecord } from '@/types'
import toast from 'react-hot-toast'

export default function BreachesPage() {
  const qc = useQueryClient()

  const { data: breaches = [], isLoading } = useQuery<BreachRecord[]>({
    queryKey: ['breaches'],
    queryFn: breachApi.list,
  })

  const checkMutation = useMutation({
    mutationFn: breachApi.check,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['breaches'] })
      qc.invalidateQueries({ queryKey: ['dashboard'] })
      toast.success('Breach check complete')
    },
    onError: () => toast.error('Breach check failed'),
  })

  const remediateMutation = useMutation({
    mutationFn: breachApi.remediate,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['breaches'] })
      qc.invalidateQueries({ queryKey: ['dashboard'] })
      toast.success('Breach marked as remediated')
    },
  })

  const active = breaches.filter(b => !b.remediated)
  const resolved = breaches.filter(b => b.remediated)

  if (isLoading) return <PageLoader />

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <SectionHeader
        title="Breach Monitor"
        subtitle="Monitor data breaches that may have exposed your personal information"
        action={
          <button
            onClick={() => checkMutation.mutate()}
            disabled={checkMutation.isPending}
            className="btn-primary"
          >
            {checkMutation.isPending
              ? <><RefreshCw className="w-4 h-4 animate-spin" /> Checking...</>
              : <><Search className="w-4 h-4" /> Check Now</>}
          </button>
        }
      />

      {/* Summary */}
      <div className="grid grid-cols-3 gap-4">
        <div className="card p-4 text-center">
          <p className="text-2xl font-bold text-red-400">{active.length}</p>
          <p className="text-xs text-zinc-500 mt-1">Active Breaches</p>
        </div>
        <div className="card p-4 text-center">
          <p className="text-2xl font-bold text-emerald-400">{resolved.length}</p>
          <p className="text-xs text-zinc-500 mt-1">Resolved</p>
        </div>
        <div className="card p-4 text-center">
          <p className="text-2xl font-bold text-zinc-100">{breaches.length}</p>
          <p className="text-xs text-zinc-500 mt-1">Total Found</p>
        </div>
      </div>

      {/* Active Breaches */}
      {active.length > 0 && (
        <section>
          <h2 className="section-title mb-3 flex items-center gap-2">
            <AlertTriangle className="w-4 h-4 text-red-400" /> Active Breaches ({active.length})
          </h2>
          <div className="space-y-3">
            {active.map(breach => (
              <BreachCard
                key={breach.id}
                breach={breach}
                onRemediate={() => remediateMutation.mutate(breach.id)}
                loading={remediateMutation.isPending}
              />
            ))}
          </div>
        </section>
      )}

      {/* Resolved */}
      {resolved.length > 0 && (
        <section>
          <h2 className="section-title mb-3 flex items-center gap-2">
            <CheckCircle className="w-4 h-4 text-emerald-400" /> Resolved ({resolved.length})
          </h2>
          <div className="space-y-3 opacity-60">
            {resolved.map(breach => (
              <BreachCard key={breach.id} breach={breach} resolved />
            ))}
          </div>
        </section>
      )}

      {breaches.length === 0 && (
        <EmptyState
          icon={ShieldAlert}
          title="No breaches found"
          description="Your email hasn't appeared in any known data breaches. Click 'Check Now' to run a fresh scan."
          action={
            <button onClick={() => checkMutation.mutate()} className="btn-primary">
              <Search className="w-4 h-4" /> Run Breach Check
            </button>
          }
        />
      )}
    </div>
  )
}

function BreachCard({
  breach, onRemediate, loading, resolved
}: {
  breach: BreachRecord
  onRemediate?: () => void
  loading?: boolean
  resolved?: boolean
}) {
  return (
    <div className={`card p-5 ${!resolved ? 'border-red-500/20' : ''}`}>
      <div className="flex items-start gap-4">
        {/* Logo placeholder */}
        <div className="w-10 h-10 rounded-lg bg-surface-800 border border-surface-700 flex items-center justify-center shrink-0">
          <ShieldAlert className={`w-5 h-5 ${resolved ? 'text-zinc-500' : 'text-red-400'}`} />
        </div>

        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 flex-wrap">
            <h3 className="font-semibold text-zinc-100">{breach.title}</h3>
            {breach.sensitive && (
              <span className="badge bg-purple-500/10 text-purple-400 border-purple-500/20">Sensitive</span>
            )}
            {resolved && (
              <span className="badge bg-emerald-500/10 text-emerald-400 border-emerald-500/20">
                <CheckCircle className="w-3 h-3" /> Resolved
              </span>
            )}
            {!resolved && (
              <span className="badge bg-red-500/10 text-red-400 border-red-500/20">
                <AlertTriangle className="w-3 h-3" /> Action Required
              </span>
            )}
          </div>

          <div className="flex items-center gap-4 mt-1 text-xs text-zinc-500">
            <span className="flex items-center gap-1">
              <Calendar className="w-3 h-3" />
              {breach.breachDate ? formatDate(breach.breachDate) : 'Unknown date'}
            </span>
            {breach.pwnCount && (
              <span className="flex items-center gap-1">
                <Users className="w-3 h-3" />
                {formatNumber(breach.pwnCount)} accounts affected
              </span>
            )}
            {breach.domain && <span>{breach.domain}</span>}
          </div>

          <p className="text-xs text-zinc-400 mt-2 leading-relaxed line-clamp-2">
            {breach.description}
          </p>

          {breach.dataClasses && breach.dataClasses.length > 0 && (
            <div className="mt-2">
              <span className="text-xs text-zinc-500 mr-2">Exposed data:</span>
              {breach.dataClasses.map(dc => (
                <span key={dc} className="inline-block text-xs px-1.5 py-0.5 rounded bg-red-500/10 text-red-400 border border-red-500/20 mr-1 mb-1">
                  {dc}
                </span>
              ))}
            </div>
          )}
        </div>

        {!resolved && onRemediate && (
          <button
            onClick={onRemediate}
            disabled={loading}
            className="btn-secondary shrink-0"
          >
            <CheckCircle className="w-3.5 h-3.5" />
            Mark Resolved
          </button>
        )}
      </div>
    </div>
  )
}
