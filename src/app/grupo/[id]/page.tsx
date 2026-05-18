import { redirect, notFound } from 'next/navigation'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'
import { CopyInviteLinkButton } from '@/components/groups/copy-invite-link-button'

interface Props {
  params: Promise<{ id: string }>
  searchParams: Promise<{ nuevo?: string }>
}

export default async function GrupoPage({ params, searchParams }: Props) {
  const { id } = await params
  const { nuevo } = await searchParams

  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/')

  const { data: group, error } = await supabase
    .from('groups')
    .select(`
      id, name, invite_code, created_by, penalty_text, created_at,
      group_members (
        user_id, role, score, joined_at,
        profiles (display_name, avatar_url)
      )
    `)
    .eq('id', id)
    .single() as any

  if (error || !group) notFound()

  const members = group.group_members as any[]
  const isMember = members.some(m => m.user_id === user.id)
  if (!isMember) redirect('/dashboard')

  const inviteUrl = `${process.env.NEXT_PUBLIC_APP_URL}/invite/${group.invite_code}`

  return (
    <main className="min-h-screen bg-[#0C0C0C] px-4 pt-8 pb-24 max-w-lg mx-auto">
      <div className="mb-6">
        <Link href="/dashboard" className="text-[#555] hover:text-white transition-colors text-sm">
          ← Mis grupos
        </Link>
      </div>

      {nuevo === 'true' && (
        <div className="bg-[#F5A62312] border border-[#F5A62340] rounded-xl p-4 mb-6">
          <p className="text-[#F5A623] font-semibold text-sm mb-1">¡Grupo creado! 🎉</p>
          <p className="text-[#888] text-xs">Compartí el link para que tu gente pueda sumarse.</p>
        </div>
      )}

      <div className="mb-6">
        <h1 className="text-white font-bold text-2xl tracking-tight mb-1">{group.name}</h1>
        {group.penalty_text && (
          <div className="mt-3 bg-[#161616] border border-[#262626] rounded-lg p-3">
            <p className="text-[#555] text-xs uppercase tracking-wider font-medium mb-1">
              El último tiene que...
            </p>
            <p className="text-[#888] text-sm">{group.penalty_text}</p>
          </div>
        )}
      </div>

      {/* Invitar */}
      <div className="bg-[#161616] border border-[#262626] rounded-xl p-4 mb-6">
        <p className="text-white font-semibold text-sm mb-1">Invitar al grupo</p>
        <p className="text-[#555] text-xs mb-3">Cualquiera con este link puede unirse.</p>
        <div className="flex items-center gap-2 bg-[#0C0C0C] rounded-lg border border-[#2E2E2E] px-3 py-2.5 mb-3">
          <span className="text-[#555] text-xs font-mono truncate flex-1">{inviteUrl}</span>
        </div>
        <CopyInviteLinkButton url={inviteUrl} />
      </div>

      {/* Miembros */}
      <section>
        <h2 className="text-[#888] text-xs font-medium uppercase tracking-wider mb-3">
          Miembros · {members.length}
        </h2>
        <div className="flex flex-col gap-2">
          {members.map((member: any) => {
            const profile = member.profiles
            const isCurrentUser = member.user_id === user.id
            const isGroupOwner = member.user_id === group.created_by  // ← created_by

            return (
              <div
                key={member.user_id}
                className="flex items-center justify-between bg-[#161616] rounded-lg border border-[#262626] px-4 py-3"
              >
                <div className="flex items-center gap-3">
                  <div className="w-7 h-7 rounded-full bg-[#2E2E2E] flex items-center justify-center text-xs font-semibold text-[#888]">
                    {profile?.display_name?.[0]?.toUpperCase() ?? '?'}
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-white text-sm">
                      {profile?.display_name ?? 'Sin nombre'}
                      {isCurrentUser && <span className="text-[#555] text-xs ml-1">(vos)</span>}
                    </span>
                    {isGroupOwner && (
                      <span className="text-[10px] text-[#F5A623] bg-[#F5A62318] px-1.5 py-0.5 rounded">
                        Admin
                      </span>
                    )}
                  </div>
                </div>
                <span className="text-[#555] text-xs font-mono">{member.score ?? 0} pts</span>
              </div>
            )
          })}
        </div>
      </section>

      <div className="mt-8">
        <div className="bg-[#161616] border border-[#262626] rounded-xl p-4 text-center">
          <p className="text-[#888] text-sm mb-1">Las predicciones abren pronto</p>
          <p className="text-[#555] text-xs">
            Podés cargar tus predicciones de fase de grupos hasta el 11 de junio.
          </p>
        </div>
      </div>
    </main>
  )
}
