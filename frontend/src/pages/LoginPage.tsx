import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { Shield, Eye, EyeOff, Loader2 } from 'lucide-react'
import { useAuthStore } from '@/store/authStore'
import { authApi } from '@/api'
import toast from 'react-hot-toast'

export default function LoginPage() {
  const [email, setEmail] = useState('demo@privacyos.io')
  const [password, setPassword] = useState('Demo@1234')
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const { setAuth } = useAuthStore()
  const navigate = useNavigate()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    try {
      const data = await authApi.login({ email, password })
      setAuth(data.user, data.accessToken, data.refreshToken)
      toast.success(`Welcome back, ${data.user.fullName || data.user.email}!`)
      navigate('/dashboard')
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Invalid email or password')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-surface-950 flex">
      {/* Left - Branding */}
      <div className="hidden lg:flex flex-col w-[480px] bg-surface-900 border-r border-surface-800 p-12">
        <div className="flex items-center gap-3 mb-16">
          <div className="w-10 h-10 rounded-xl bg-brand-600 flex items-center justify-center">
            <Shield className="w-5 h-5 text-white" />
          </div>
          <span className="text-xl font-bold text-zinc-50">PrivacyOS</span>
        </div>

        <div className="flex-1 flex flex-col justify-center">
          <h1 className="text-4xl font-bold text-zinc-50 leading-tight mb-4">
            Your privacy,<br />
            <span className="text-gradient">under control.</span>
          </h1>
          <p className="text-zinc-400 text-lg leading-relaxed mb-10">
            Understand, monitor, and control your digital footprint across the internet.
          </p>

          <div className="space-y-4">
            {[
              { icon: '🛡️', text: 'Real-time breach monitoring' },
              { icon: '🔍', text: 'AI-powered permission analysis' },
              { icon: '📊', text: 'Privacy score tracking' },
              { icon: '🕸️', text: 'Interactive data ownership graph' },
            ].map(({ icon, text }) => (
              <div key={text} className="flex items-center gap-3">
                <span className="text-xl">{icon}</span>
                <span className="text-zinc-300 text-sm">{text}</span>
              </div>
            ))}
          </div>
        </div>

        <p className="text-xs text-zinc-600">
          © 2026 PrivacyOS. All rights reserved.
        </p>
      </div>

      {/* Right - Form */}
      <div className="flex-1 flex items-center justify-center p-8">
        <div className="w-full max-w-sm">
          <div className="lg:hidden flex items-center gap-2 mb-8 justify-center">
            <div className="w-8 h-8 rounded-lg bg-brand-600 flex items-center justify-center">
              <Shield className="w-4 h-4 text-white" />
            </div>
            <span className="font-bold text-zinc-50">PrivacyOS</span>
          </div>

          <h2 className="text-2xl font-bold text-zinc-50 mb-1">Sign in</h2>
          <p className="text-zinc-500 text-sm mb-8">
            Don't have an account?{' '}
            <Link to="/register" className="text-brand-400 hover:text-brand-300 font-medium">
              Create one
            </Link>
          </p>

          {/* Demo credentials hint */}
          <div className="mb-6 p-3 rounded-lg bg-brand-600/10 border border-brand-500/20">
            <p className="text-xs text-brand-400 font-medium">Demo credentials pre-filled</p>
            <p className="text-xs text-zinc-500 mt-0.5">email: demo@privacyos.io / password: Demo@1234</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="label mb-1.5 block">Email address</label>
              <input
                type="email"
                value={email}
                onChange={e => setEmail(e.target.value)}
                className="input"
                placeholder="you@example.com"
                required
                autoFocus
              />
            </div>
            <div>
              <label className="label mb-1.5 block">Password</label>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={e => setPassword(e.target.value)}
                  className="input pr-10"
                  placeholder="••••••••"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-zinc-500 hover:text-zinc-300"
                >
                  {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="btn-primary w-full justify-center py-2.5 mt-2"
            >
              {loading ? (
                <><Loader2 className="w-4 h-4 animate-spin" /> Signing in...</>
              ) : 'Sign in'}
            </button>
          </form>
        </div>
      </div>
    </div>
  )
}
