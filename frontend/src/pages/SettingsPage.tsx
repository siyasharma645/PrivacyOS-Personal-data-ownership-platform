import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { User, Shield, Bell, Trash2, Save, RefreshCw, AlertTriangle } from 'lucide-react'
import { authApi, dashboardApi } from '@/api'
import { useAuthStore } from '@/store/authStore'
import { SectionHeader, PageLoader } from '@/components/ui'
import PrivacyScoreRing from '@/components/dashboard/PrivacyScoreRing'
import { formatDate } from '@/utils'
import toast from 'react-hot-toast'

export default function SettingsPage() {
  const { user, setUser } = useAuthStore()
  const qc = useQueryClient()
  const [activeTab, setActiveTab] = useState<'profile' | 'privacy' | 'danger'>('profile')

  const { data: scoreData } = useQuery({
    queryKey: ['score'],
    queryFn: dashboardApi.getScore,
  })

  const recalcMutation = useMutation({
    mutationFn: dashboardApi.recalculate,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['dashboard'] })
      qc.invalidateQueries({ queryKey: ['score'] })
      toast.success('Privacy score recalculated')
    },
  })

  const tabs = [
    { id: 'profile', label: 'Profile', icon: User },
    { id: 'privacy', label: 'Privacy', icon: Shield },
    { id: 'danger', label: 'Danger Zone', icon: AlertTriangle },
  ] as const

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <SectionHeader title="Settings" subtitle="Manage your account and privacy preferences" />

      {/* Tabs */}
      <div className="flex gap-1 p-1 bg-surface-800 rounded-xl w-fit">
        {tabs.map(({ id, label, icon: Icon }) => (
          <button
            key={id}
            onClick={() => setActiveTab(id)}
            className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition-all ${
              activeTab === id
                ? 'bg-surface-900 text-zinc-100 shadow'
                : 'text-zinc-500 hover:text-zinc-300'
            }`}
          >
            <Icon className="w-3.5 h-3.5" />
            {label}
          </button>
        ))}
      </div>

      {/* Profile Tab */}
      {activeTab === 'profile' && (
        <div className="space-y-4">
          <div className="card p-6 space-y-5">
            <h2 className="font-semibold text-zinc-100">Account Information</h2>

            <div className="flex items-center gap-4">
              <div className="w-16 h-16 rounded-full bg-brand-600 flex items-center justify-center text-2xl font-bold text-white">
                {user?.fullName?.[0]?.toUpperCase() ?? user?.email[0].toUpperCase()}
              </div>
              <div>
                <p className="font-medium text-zinc-100">{user?.fullName}</p>
                <p className="text-sm text-zinc-500">{user?.email}</p>
                <span className="badge badge-info mt-1">{user?.provider}</span>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="label mb-1.5 block">Full Name</label>
                <input defaultValue={user?.fullName ?? ''} className="input" placeholder="Your name" readOnly />
              </div>
              <div>
                <label className="label mb-1.5 block">Email</label>
                <input defaultValue={user?.email ?? ''} className="input" readOnly />
              </div>
              <div>
                <label className="label mb-1.5 block">Account Type</label>
                <input value={user?.role ?? 'USER'} className="input" readOnly />
              </div>
              <div>
                <label className="label mb-1.5 block">Member Since</label>
                <input value={user?.createdAt ? formatDate(user.createdAt) : '–'} className="input" readOnly />
              </div>
            </div>

            <div className="pt-2 border-t border-surface-800 flex justify-end">
              <button className="btn-primary" onClick={() => toast('Profile updates coming soon')}>
                <Save className="w-4 h-4" /> Save Changes
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Privacy Tab */}
      {activeTab === 'privacy' && (
        <div className="space-y-4">
          {/* Score Overview */}
          <div className="card p-6">
            <h2 className="font-semibold text-zinc-100 mb-4">Privacy Score</h2>
            <div className="flex items-center gap-6">
              <PrivacyScoreRing score={user?.privacyScore ?? 50} size={100} />
              <div className="space-y-3 flex-1">
                {scoreData && [
                  { label: 'Permission Risk', value: scoreData.permissionPenalty, max: 100 },
                  { label: 'Breach Exposure', value: scoreData.breachPenalty, max: 100 },
                  { label: 'Third-Party Sharing', value: scoreData.thirdPartyPenalty, max: 50 },
                  { label: 'Account Sprawl', value: scoreData.sprawlPenalty, max: 50 },
                  { label: 'Data Staleness', value: scoreData.stalenessPenalty, max: 50 },
                ].map(({ label, value, max }) => (
                  <div key={label}>
                    <div className="flex justify-between text-xs mb-1">
                      <span className="text-zinc-400">{label}</span>
                      <span className="text-zinc-500">-{value} pts</span>
                    </div>
                    <div className="h-1.5 bg-surface-700 rounded-full overflow-hidden">
                      <div
                        className="h-full rounded-full transition-all"
                        style={{
                          width: `${(value / max) * 100}%`,
                          backgroundColor: value > max * 0.6 ? '#ef4444' : value > max * 0.3 ? '#f59e0b' : '#22c55e'
                        }}
                      />
                    </div>
                  </div>
                ))}
              </div>
            </div>
            <div className="mt-4 pt-4 border-t border-surface-800">
              <button
                onClick={() => recalcMutation.mutate()}
                disabled={recalcMutation.isPending}
                className="btn-secondary"
              >
                <RefreshCw className={`w-4 h-4 ${recalcMutation.isPending ? 'animate-spin' : ''}`} />
                Recalculate Score
              </button>
            </div>
          </div>

          {/* Privacy Preferences */}
          <div className="card p-6 space-y-4">
            <h2 className="font-semibold text-zinc-100">Privacy Preferences</h2>
            {[
              { label: 'Breach Alerts', desc: 'Get notified when new breaches are detected', enabled: true },
              { label: 'Weekly Privacy Report', desc: 'Receive a weekly summary of your privacy posture', enabled: true },
              { label: 'High-Risk Permission Warnings', desc: 'Alert when high-risk permissions are detected', enabled: true },
            ].map(({ label, desc, enabled }) => (
              <div key={label} className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-zinc-200">{label}</p>
                  <p className="text-xs text-zinc-500">{desc}</p>
                </div>
                <button
                  onClick={() => toast('Notification settings coming soon')}
                  className={`w-10 h-5 rounded-full transition-colors ${enabled ? 'bg-brand-600' : 'bg-surface-700'}`}
                >
                  <div className={`w-4 h-4 rounded-full bg-white shadow transition-transform mx-0.5 ${enabled ? 'translate-x-5' : 'translate-x-0'}`} />
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Danger Zone */}
      {activeTab === 'danger' && (
        <div className="card border-red-500/20 p-6 space-y-4">
          <h2 className="font-semibold text-red-400 flex items-center gap-2">
            <AlertTriangle className="w-4 h-4" /> Danger Zone
          </h2>
          <p className="text-sm text-zinc-400">
            These actions are irreversible. Please proceed with caution.
          </p>

          <div className="space-y-3">
            <div className="flex items-center justify-between p-4 rounded-lg border border-red-500/20 bg-red-500/5">
              <div>
                <p className="text-sm font-medium text-zinc-200">Clear all privacy data</p>
                <p className="text-xs text-zinc-500 mt-0.5">Remove all events, recommendations and score history</p>
              </div>
              <button onClick={() => toast.error('This would delete all your privacy data')} className="btn-danger">
                <Trash2 className="w-4 h-4" /> Clear Data
              </button>
            </div>

            <div className="flex items-center justify-between p-4 rounded-lg border border-red-500/20 bg-red-500/5">
              <div>
                <p className="text-sm font-medium text-zinc-200">Delete account</p>
                <p className="text-xs text-zinc-500 mt-0.5">Permanently delete your PrivacyOS account and all data</p>
              </div>
              <button onClick={() => toast.error('Account deletion not available in demo')} className="btn-danger">
                <Trash2 className="w-4 h-4" /> Delete Account
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
