import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { Shield, Eye, EyeOff, Loader2 } from 'lucide-react'
import { useAuthStore } from '@/store/authStore'
import { authApi } from '@/api'
import toast from 'react-hot-toast'

export default function RegisterPage() {
  const [form, setForm] = useState({ email: '', password: '', fullName: '' })
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const { setAuth } = useAuthStore()
  const navigate = useNavigate()

  const set = (k: string) => (e: React.ChangeEvent<HTMLInputElement>) =>
    setForm(f => ({ ...f, [k]: e.target.value }))

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (form.password.length < 8) {
      toast.error('Password must be at least 8 characters')
      return
    }
    setLoading(true)
    try {
      const data = await authApi.register(form)
      setAuth(data.user, data.accessToken, data.refreshToken)
      toast.success('Account created! Welcome to PrivacyOS.')
      navigate('/dashboard')
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Registration failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-surface-950 flex items-center justify-center p-8">
      <div className="w-full max-w-sm">
        <div className="flex items-center gap-2 mb-8 justify-center">
          <div className="w-8 h-8 rounded-lg bg-brand-600 flex items-center justify-center">
            <Shield className="w-4 h-4 text-white" />
          </div>
          <span className="font-bold text-zinc-50">PrivacyOS</span>
        </div>

        <h2 className="text-2xl font-bold text-zinc-50 mb-1 text-center">Create your account</h2>
        <p className="text-zinc-500 text-sm mb-8 text-center">
          Already have one?{' '}
          <Link to="/login" className="text-brand-400 hover:text-brand-300 font-medium">Sign in</Link>
        </p>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="label mb-1.5 block">Full name</label>
            <input type="text" value={form.fullName} onChange={set('fullName')}
              className="input" placeholder="Alex Rivera" required />
          </div>
          <div>
            <label className="label mb-1.5 block">Email address</label>
            <input type="email" value={form.email} onChange={set('email')}
              className="input" placeholder="you@example.com" required />
          </div>
          <div>
            <label className="label mb-1.5 block">Password</label>
            <div className="relative">
              <input type={showPassword ? 'text' : 'password'} value={form.password}
                onChange={set('password')} className="input pr-10"
                placeholder="Min. 8 characters" required minLength={8} />
              <button type="button" onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-zinc-500 hover:text-zinc-300">
                {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
          </div>

          <button type="submit" disabled={loading}
            className="btn-primary w-full justify-center py-2.5 mt-2">
            {loading ? <><Loader2 className="w-4 h-4 animate-spin" /> Creating account...</> : 'Create account'}
          </button>
        </form>

        <p className="text-xs text-zinc-600 text-center mt-6">
          By creating an account you agree to our Terms of Service and Privacy Policy.
        </p>
      </div>
    </div>
  )
}
