'use client'

// app/page.tsx
// Landing/Login — magic link via email
// Mobile-first, español

import { useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [loading, setLoading] = useState(false)
  const [sent, setSent] = useState(false)
  const [error, setError] = useState<string | null>(null)

  async function handleLogin(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError(null)

    const supabase = createClient()
    const { error } = await supabase.auth.signInWithOtp({
      email,
      options: {
        emailRedirectTo: `${window.location.origin}/auth/callback`,
      },
    })

    if (error) {
      setError('Algo salió mal. Revisá el email e intentá de nuevo.')
    } else {
      setSent(true)
    }

    setLoading(false)
  }

  return (
    <main className="min-h-screen bg-[#0C0C0C] flex flex-col items-center justify-center px-5">
      {/* Logo / Marca */}
      <div className="mb-10 text-center">
        <div className="font-black text-5xl tracking-tighter text-white leading-none mb-1">
          PRODE<span className="text-[#F5A623]">26</span>
        </div>
        <p className="text-[#888] text-sm font-medium tracking-widest uppercase">
          Mundial · Grupo · Memoria
        </p>
      </div>

      {/* Card */}
      <div className="w-full max-w-sm bg-[#161616] rounded-2xl border border-[#262626] p-6">
        {!sent ? (
          <>
            <h1 className="text-white font-semibold text-lg mb-1">
              Entrar al prode
            </h1>
            <p className="text-[#888] text-sm mb-6">
              Te mandamos un link al email — sin contraseña.
            </p>

            <form onSubmit={handleLogin} className="flex flex-col gap-3">
              <Input
                type="email"
                placeholder="tu@email.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                autoComplete="email"
                className="bg-[#1E1E1E] border-[#2E2E2E] text-white placeholder:text-[#555] focus-visible:ring-[#F5A623] focus-visible:border-[#F5A623] h-11"
              />

              {error && (
                <p className="text-red-400 text-xs">{error}</p>
              )}

              <Button
                type="submit"
                disabled={loading || !email}
                className="bg-[#F5A623] text-black font-semibold h-11 hover:bg-[#E8981A] disabled:opacity-40"
              >
                {loading ? 'Enviando...' : 'Entrar →'}
              </Button>
            </form>

            <p className="text-[#555] text-xs text-center mt-4">
              Al entrar aceptás los términos de uso.
            </p>
          </>
        ) : (
          <div className="text-center py-2">
            <div className="text-4xl mb-4">📬</div>
            <h2 className="text-white font-semibold text-lg mb-2">
              Revisá tu correo
            </h2>
            <p className="text-[#888] text-sm">
              Mandamos un link a{' '}
              <span className="text-white font-medium">{email}</span>.
              Hacé click en él para entrar.
            </p>
            <button
              onClick={() => { setSent(false); setEmail('') }}
              className="text-[#F5A623] text-sm mt-4 underline-offset-2 hover:underline"
            >
              Usar otro email
            </button>
          </div>
        )}
      </div>

      {/* Footer hint */}
      <p className="text-[#444] text-xs text-center mt-8 max-w-xs">
        Prode26 es gratuito. Sin apuestas, sin plata. Solo orgullo.
      </p>
    </main>
  )
}
