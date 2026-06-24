import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  RefreshCw, Trash2, ChevronDown, ChevronUp, Shield,
  Clock, AlertTriangle, CheckCircle, X, Eye, Loader2
} from 'lucide-react'
import { accountsApi, aiApi } from '@/api'
import { SectionHeader, PageLoader, EmptyState, ProviderIcon } from '@/components/ui'
import RiskBadge from '@/components/ui/RiskBadge'
import { formatRelativeTime, formatDate } from '@/utils'
import type { ConnectedAccount, Permission } from '@/types'
import toast from 'react-hot-toast'
import { Link2 } from 'lucide-react'

export default function AccountsPage() {
  const qc = useQueryClient()
  const [expandedId, setExpandedId] = useState<string | null>(null)
  const [aiExplain, setAiExplain] = useState<{ permId: string; text: string } | null>(null)
  const [explaining, setExplaining] = useState<string | null>(null)

  const { data: accounts = [], isLoading } = useQuery<ConnectedAccount[]>({
    queryKey: ['accounts'],
    queryFn: accountsApi.list,
  })

  const syncMutation = useMutation({
    mutationFn: accountsApi.sync,
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['accounts'] }); toast.success('Account synced') },
    onError: () => toast.error('Sync failed'),
  })

  const disconnectMutation = useMutation({
    mutationFn: accountsApi.disconnect,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['accounts'] })
      qc.invalidateQueries({ queryKey: ['dashboard'] })
      toast.success('Account disconnected')
    },
    onError: () => toast.error('Failed to disconnect'),
  })

  const revokeMutation = useMutation({
    mutationFn: accountsApi.revokePermission,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['accounts'] })
      qc.invalidateQueries({ queryKey: ['dashboard'] })
      toast.success('Permission revoked')
    },
    onError: () => toast.error('Failed to revoke permission'),
  })

  const handleExplain = async (perm: Permission) => {
    setExplaining(perm.id)
    try {
      const data = await aiApi.explainPermission(perm.id)
      setAiExplain({ permId: perm.id, text: data.explanation })
    } catch {
      toast.error('AI explanation unavailable')
    } finally {
      setExplaining(null)
    }
  }

  if (isLoading) return <PageLoader />

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <SectionHeader
        title="Connected Accounts"
        subtitle={`${accounts.length} account${accounts.length !== 1 ? 's' : ''} connected — manage OAuth connections and permissions`}
      />

      {accounts.length === 0 && (
        <EmptyState
          icon={Link2}
          title="No accounts connected"
          description="Connect your Google, GitHub, or LinkedIn accounts to start monitoring your privacy."
        />
      )}

      <div className="space-y-3">
        {accounts.map(account => (
          <div key={account.id} className="card overflow-hidden">
            {/* Account Header */}
            <div className="flex items-center gap-4 p-5">
              <ProviderIcon provider={account.provider} size="lg" />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <h3 className="font-semibold text-zinc-100">{account.provider}</h3>
                  <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${
                    account.status === 'ACTIVE'
                      ? 'bg-emerald-500/10 text-emerald-400'
                      : 'bg-red-500/10 text-red-400'
                  }`}>{account.status}</span>
                </div>
                <p className="text-sm text-zinc-500 truncate">{account.providerEmail}</p>
                <div className="flex items-center gap-4 mt-1">
                  <span className="text-xs text-zinc-500 flex items-center gap-1">
                    <Shield className="w-3 h-3" /> {account.permissionCount} permissions
                  </span>
                  {account.highRiskCount > 0 && (
                    <span className="text-xs text-orange-400 flex items-center gap-1">
                      <AlertTriangle className="w-3 h-3" /> {account.highRiskCount} high-risk
                    </span>
                  )}
                  {account.lastSyncedAt && (
                    <span className="text-xs text-zinc-500 flex items-center gap-1">
                      <Clock className="w-3 h-3" /> {formatRelativeTime(account.lastSyncedAt)}
                    </span>
                  )}
                </div>
              </div>

              {/* Actions */}
              <div className="flex items-center gap-2 shrink-0">
                <button
                  onClick={() => syncMutation.mutate(account.id)}
                  disabled={syncMutation.isPending}
                  className="btn-secondary"
                >
                  <RefreshCw className={`w-3.5 h-3.5 ${syncMutation.isPending ? 'animate-spin' : ''}`} />
                  Sync
                </button>
                <button
                  onClick={() => {
                    if (confirm(`Disconnect ${account.provider}? This will remove all associated permissions.`)) {
                      disconnectMutation.mutate(account.id)
                    }
                  }}
                  className="btn-danger"
                >
                  <Trash2 className="w-3.5 h-3.5" />
                </button>
                <button
                  onClick={() => setExpandedId(expandedId === account.id ? null : account.id)}
                  className="btn-ghost"
                >
                  {expandedId === account.id
                    ? <ChevronUp className="w-4 h-4" />
                    : <ChevronDown className="w-4 h-4" />}
                </button>
              </div>
            </div>

            {/* Permissions Expanded */}
            {expandedId === account.id && (
              <div className="border-t border-surface-800 bg-surface-950/50 p-5">
                <h4 className="text-xs font-semibold text-zinc-400 uppercase tracking-wider mb-3">
                  Granted Permissions ({account.permissions.length})
                </h4>
                {account.permissions.length === 0 ? (
                  <p className="text-sm text-zinc-500">No active permissions</p>
                ) : (
                  <div className="space-y-2">
                    {account.permissions.map(perm => (
                      <div key={perm.id}>
                        <div className="flex items-start gap-3 p-3 rounded-lg bg-surface-800 border border-surface-700">
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center gap-2 flex-wrap">
                              <span className="text-sm font-medium text-zinc-200">{perm.displayName}</span>
                              <RiskBadge level={perm.riskLevel} size="sm" />
                              {perm.sensitive && (
                                <span className="badge bg-purple-500/10 text-purple-400 border-purple-500/20">Sensitive</span>
                              )}
                            </div>
                            <p className="text-xs text-zinc-500 mt-1">{perm.description}</p>
                            {perm.dataTypes && perm.dataTypes.length > 0 && (
                              <div className="flex flex-wrap gap-1 mt-2">
                                {perm.dataTypes.map(dt => (
                                  <span key={dt} className="text-xs px-1.5 py-0.5 rounded bg-surface-700 text-zinc-400">{dt}</span>
                                ))}
                              </div>
                            )}
                            {/* AI Explanation */}
                            {aiExplain?.permId === perm.id && (
                              <div className="mt-2 p-2 rounded bg-brand-600/10 border border-brand-500/20">
                                <p className="text-xs text-brand-300">🤖 {aiExplain.text}</p>
                              </div>
                            )}
                          </div>
                          <div className="flex gap-2 shrink-0">
                            <button
                              onClick={() => handleExplain(perm)}
                              disabled={explaining === perm.id}
                              className="btn-ghost py-1 text-xs"
                            >
                              {explaining === perm.id
                                ? <Loader2 className="w-3 h-3 animate-spin" />
                                : <Eye className="w-3 h-3" />}
                              Explain
                            </button>
                            {perm.revocable && (
                              <button
                                onClick={() => {
                                  if (confirm(`Revoke "${perm.displayName}"?`)) {
                                    revokeMutation.mutate(perm.id)
                                  }
                                }}
                                className="btn-danger py-1 text-xs"
                              >
                                <X className="w-3 h-3" /> Revoke
                              </button>
                            )}
                            {!perm.revocable && (
                              <span className="text-xs text-zinc-600 flex items-center gap-1">
                                <CheckCircle className="w-3 h-3" /> Required
                              </span>
                            )}
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Add Account Placeholder */}
      <div className="card border-dashed border-surface-700 p-8 flex flex-col items-center gap-3 text-center">
        <div className="w-10 h-10 rounded-full bg-surface-800 flex items-center justify-center">
          <Link2 className="w-5 h-5 text-zinc-500" />
        </div>
        <div>
          <p className="text-sm font-medium text-zinc-300">Connect another account</p>
          <p className="text-xs text-zinc-500 mt-1">
            OAuth connections are configured via the backend. Add your Google client credentials to enable live OAuth.
          </p>
        </div>
      </div>
    </div>
  )
}
