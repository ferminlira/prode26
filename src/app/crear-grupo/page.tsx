'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Button } from '@/components/ui/button'
import { nanoid } from 'nanoid'

export default function CrearGrupoPage() {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [form, setForm] = useState({ name: '', penalty_text: '' })

  function handleChange(e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) {
    setForm(prev => ({ ...prev, [e.target.name]: e.target.value }))
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError(null)

    const supabase = createClient()
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) { router.push('/'); return }

    const invite_code = nanoid(8)

    const { data: group, error: groupError } = await supabase
      .from('groups')
      .insert({
        name: form.name.trim(),
        created_by: user.id,
        invite_code,
        penalty_text: form.penalty_text.trim() || null,
      } as any)
      .select('id, invite_code')
      .single() as any

    if (groupError || !group) {
      setError('No se pudo crear el grupo. Intentá de nuevo.')
      setLoading(false)
      return
    }

    await supabase.from('group_members').insert({
      group_id: group.id,
      user_id: user.id,
      role: 'admin',
    } as any)

    router.push(`/grupo/${group.id}?nuevo=true`)
  }

  return (
    <main className="min-h-screen bg-[#0C0C0C] px-4 pt-8 pb-24 max-w-lg mx-auto">
      <div className="mb-6">
        <Link href="/dashboard" className="text-[#555] hover:text-white transition-colors text-sm">
          ← Volver
        </Link>
      </div>

      <div className="mb-6">
        <h1 className="text-white font-bold text-xl mb-1">Nuevo grupo</h1>
        <p className="text-[#555] text-sm">
          Después de crear el grupo vas a tener el link para invitar a tu gente.
        </p>
      </div>

      <form onSubmit={handleSubmit} className="flex flex-col gap-5">
        <div>
          <label className="text-[#888] text-xs font-medium uppercase tracking-wider block mb-2">
            Nombre del grupo
          </label>
          <Input
            name="name"
            value={form.name}
            onChange={handleChange}
            placeholder="ej: La oficina del jueves"
            required
            maxLength={50}
            className="bg-[#161616] border-[#2E2E2E] text-white placeholder:text-[#444] focus-visible:ring-[#F5A623] focus-visible:border-[#F5A623] h-11"
          />
        </div>

        <div>
          <label className="text-[#888] text-xs font-medium uppercase tracking-wider block mb-2">
            ¿Qué tiene que hacer el último?{' '}
            <span className="text-[#555] normal-case">(opcional)</span>
          </label>
          <Textarea
            name="penalty_text"
            value={form.penalty_text}
            onChange={handleChange}
            placeholder="ej: Tiene que llevar alfajores a la próxima junta 🍫"
            maxLength={200}
            rows={3}
            className="bg-[#161616] border-[#2E2E2E] text-white placeholder:text-[#444] focus-visible:ring-[#F5A623] focus-visible:border-[#F5A623] resize-none"
          />
          <p className="text-[#444] text-xs mt-1.5">
            Queda guardado y se les recuerda a todos al final del torneo.
          </p>
        </div>

        {error && <p className="text-red-400 text-sm">{error}</p>}

        <Button
          type="submit"
          disabled={loading || !form.name.trim()}
          className="bg-[#F5A623] text-black font-semibold h-12 hover:bg-[#E8981A] disabled:opacity-40 text-sm mt-2"
        >
          {loading ? 'Creando...' : 'Crear grupo →'}
        </Button>
      </form>
    </main>
  )
}
