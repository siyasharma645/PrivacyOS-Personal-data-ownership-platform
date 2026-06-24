import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Lightbulb, CheckCircle, X, RefreshCw, TrendingUp, Zap } from 'lucide-react'
import { recommendationApi } from '@/api'
import { SectionHeader, PageLoader, EmptyState } from '@/components/ui'
import RiskBadge from '@/components/ui/RiskBadge'
import { formatRelativeTime } from '@/utils'
import type { PrivacyRecommendation } from '@/types'
import toast from 'react-hot-toast'

const TYPE_ICONS: Record<string, string> = {
  REVOKE_PERMISSION: '🔑',
  CHANGE_PASSWORD: '🔒',
  ENABLE_2FA: '📱',
  REVIEW_PERMISSIONS: '👁️',
  REMEDIATE_BREACH: '🚨',
  REDUCE_SPRAWL: '🧹',
  REVIEW_ACCOUNT: '⚙️',
}

export default function RecommendationsPage() {
  const qc = useQueryClient()

  const { data: recs = [], isLoading } = useQuery<PrivacyRecommendation[]>({
    queryKey: ['recommendations'],
    queryFn: recommendationApi.list,
  })

  const generateMutation = useMutation({
    mutationFn: recommendationApi.generate,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['recommendations'] })
      toast.success('New recommendations generated')
    },
  })

  const completeMutation = useMutation({
    mutationFn: recommendationApi.complete,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['recommendations'] })
      qc.invalidateQueries({ queryKey: ['dashboard'] })
      toast.success('Recommendation completed! Score updated.')
    },
  })

  const dismissMutation = useMutation({
    mutationFn: recommendationApi.dismiss,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['recommendations'] })
      toast('Recommendation dismissed')
    },
  })

  if (isLoading) return <PageLoader />

  const pending = recs.filter(r => r.status === 'PENDING')
  const completed = recs.filter(r => r.status === 'COMPLETED')
  const dismissed = recs.filter(r => r.status === 'DISMISSED')

  const totalPotential = pending.reduce((sum, r) => sum + r.expectedScoreImprovement, 0)

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <SectionHeader
        title="Privacy Recommendations"
        subtitle="Actionable steps to improve your privacy score"
        action={
          <button onClick={() => generateMutation.mutate()} disabled={generateMutation.isPending}
            className="btn-secondary">
            {generateMutation.isPending
              ? <><RefreshCw className="w-4 h-4 animate-spin" /> Generating...</>
              : <><Zap className="w-4 h-4" /> Generate New</>}
          </button>
        }
      />

      {/* Potential Score */}
      {pending.length > 0 && (
        <div className="card p-4 flex items-center gap-4 border-brand-500/20 bg-brand-600/5">
          <div className="w-10 h-10 rounded-full bg-brand-600/20 flex items-center justify-center">
            <TrendingUp className="w-5 h-5 text-brand-400" />
          </div>
          <div>
            <p className="text-sm font-semibold text-zinc-100">
              Complete all recommendations to gain up to <span className="text-brand-400">+{totalPotential} points</span>
            </p>
            <p className="text-xs text-zinc-500 mt-0.5">{pending.length} pending actions</p>
          </div>
        </div>
      )}

      {/* Pending */}
      {pending.length > 0 && (
        <section>
          <h2 className="section-title mb-3">Pending ({pending.length})</h2>
          <div className="space-y-3">
            {pending.map(rec => (
              <RecommendationCard
                key={rec.id}
                rec={rec}
                onComplete={() => completeMutation.mutate(rec.id)}
                onDismiss={() => dismissMutation.mutate(rec.id)}
                loading={completeMutation.isPending || dismissMutation.isPending}
              />
            ))}
          </div>
        </section>
      )}

      {/* Completed */}
      {completed.length > 0 && (
        <section>
          <h2 className="section-title mb-3 flex items-center gap-2">
            <CheckCircle className="w-4 h-4 text-emerald-400" /> Completed ({completed.length})
          </h2>
          <div className="space-y-2 opacity-50">
            {completed.map(rec => (
              <div key={rec.id} className="card p-4 flex items-center gap-3">
                <CheckCircle className="w-4 h-4 text-emerald-400 shrink-0" />
                <p className="text-sm text-zinc-400 line-through">{rec.title}</p>
                <span className="ml-auto text-xs text-emerald-400">+{rec.expectedScoreImprovement}</span>
              </div>
            ))}
          </div>
        </section>
      )}

      {recs.length === 0 && (
        <EmptyState
          icon={Lightbulb}
          title="No recommendations yet"
          description="Click 'Generate New' to get personalized privacy recommendations based on your connected accounts."
          action={
            <button onClick={() => generateMutation.mutate()} className="btn-primary">
              <Zap className="w-4 h-4" /> Generate Recommendations
            </button>
          }
        />
      )}
    </div>
  )
}

function RecommendationCard({
  rec, onComplete, onDismiss, loading
}: {
  rec: PrivacyRecommendation
  onComplete: () => void
  onDismiss: () => void
  loading?: boolean
}) {
  const icon = TYPE_ICONS[rec.type] ?? '💡'

  return (
    <div className="card p-5 hover:border-zinc-600 transition-colors">
      <div className="flex items-start gap-4">
        <div className="w-10 h-10 rounded-lg bg-surface-800 flex items-center justify-center text-lg shrink-0">
          {icon}
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 flex-wrap mb-1">
            <h3 className="text-sm font-semibold text-zinc-100">{rec.title}</h3>
            <RiskBadge level={rec.priority} size="sm" />
          </div>
          <p className="text-xs text-zinc-400 leading-relaxed">{rec.description}</p>
          <div className="flex items-center gap-3 mt-2">
            <span className="text-xs text-emerald-400 font-medium flex items-center gap-1">
              <TrendingUp className="w-3 h-3" /> +{rec.expectedScoreImprovement} score
            </span>
            {rec.relatedAccountProvider && (
              <span className="text-xs text-zinc-500">via {rec.relatedAccountProvider}</span>
            )}
            <span className="text-xs text-zinc-600">{formatRelativeTime(rec.createdAt)}</span>
          </div>
        </div>
        <div className="flex gap-2 shrink-0">
          <button onClick={onComplete} disabled={loading} className="btn-primary py-1.5 text-xs">
            <CheckCircle className="w-3.5 h-3.5" />
            {rec.actionLabel || 'Done'}
          </button>
          <button onClick={onDismiss} disabled={loading} className="btn-ghost py-1.5 px-2">
            <X className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>
    </div>
  )
}
