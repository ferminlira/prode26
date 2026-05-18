// app/invite/[code]/page.tsx
// Server Component — valida el código y muestra preview del grupo
// Si el usuario ya está en el grupo, redirige directo

import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { JoinGroupButton } from '@/components/groups/join-group-button'

interface Props {
  params: Promise<{ code: string }>
}

export default async function InvitePage({ params }: Props) {
  const { code } = await params
  const supabase = await createClient()

  // Buscar el grupo por invite_code (lectura pública — teams/matches son públicos,
  // pero groups no. Usamos service_role aquí? No — usamos una función RPC o
  // una tabla pública de preview. Por simplicidad en v1, usamos anon con la
  // policy de insert que ya verifica el código válido)

  // Buscar datos básicos del grupo para mostrar preview
  // NOTA: la policy "groups: member read" solo deja ver a miembros.
  // Para el invite necesitamos ver el grupo SIN ser miembro todavía.
  // Solución v1: crear una Postgres Function (RPC) que devuelva datos
  // básicos del grupo dado un invite_code, sin requerir membresía.
  // Ver supabase/functions/get_group_preview.sql adjunto.
  const { data: preview, error } = await supabase
    .rpc('get_group_preview', { p_invite_code: code } as any)
    .single() as any

  if (error || !preview) {
    return <InvalidInvite />
  }

  // Ver si el usuario ya está logueado
  const { data: { user } } = await supabase.auth.getUser()

  // Ver si ya es miembro
  if (user) {
    const { data: existing } = await supabase
      .from('group_members')
      .select('id')
      .eq('group_id', (preview as any).group_id)
      .eq('user_id', user.id)
      .single()

    if (existing) {
      redirect(`/grupo/${(preview as any).group_id}`)
    }
  }

  return (
    <main className="min-h-screen bg-[#0C0C0C] flex flex-col items-center justify-center px-5">
      {/* Logo */}
      <div className="mb-8 text-center">
        <div className="font-black text-4xl tracking-tighter text-white leading-none">
          PRODE<span className="text-[#F5A623]">26</span>
        </div>
      </div>

      {/* Card de invitación */}
      <div className="w-full max-w-sm bg-[#161616] rounded-2xl border border-[#262626] p-6">
        <p className="text-[#555] text-xs uppercase tracking-wider font-medium mb-4">
          Te invitaron a un grupo
        </p>

        <h1 className="text-white font-bold text-xl mb-1">
          {(preview as any).group_name}
        </h1>

        <p className="text-[#888] text-sm mb-1">
          {(preview as any).member_count}{' '}
          {(preview as any).member_count === 1 ? 'miembro' : 'miembros'}
        </p>

        {(preview as any).penalty_text && (
          <div className="mt-4 bg-[#0C0C0C] rounded-lg border border-[#2E2E2E] p-3 mb-4">
            <p className="text-[#555] text-xs uppercase tracking-wider font-medium mb-1">
              El último tiene que...
            </p>
            <p className="text-[#888] text-sm">{(preview as any).penalty_text}</p>
          </div>
        )}

        <div className="mt-4">
          <JoinGroupButton
            inviteCode={code}
            groupId={(preview as any).group_id}
            isLoggedIn={!!user}
          />
        </div>
      </div>

      <p className="text-[#444] text-xs text-center mt-6 max-w-xs">
        Mundial 2026 · Sin apuestas, sin plata. Solo orgullo.
      </p>
    </main>
  )
}

function InvalidInvite() {
  return (
    <main className="min-h-screen bg-[#0C0C0C] flex flex-col items-center justify-center px-5">
      <div className="text-4xl mb-4">🔍</div>
      <h1 className="text-white font-semibold text-lg mb-2">Link inválido</h1>
      <p className="text-[#888] text-sm text-center max-w-xs">
        Este link de invitación no existe o expiró. Pedile uno nuevo a quien te invitó.
      </p>
    </main>
  )
}
