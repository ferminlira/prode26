// app/dashboard/page.tsx
// Server Component — carga grupos del usuario

import { redirect } from 'next/navigation'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'
import { Button } from '@/components/ui/button'
import { SignOutButton } from '@/components/auth/sign-out-button'
import { GroupCard } from '@/components/groups/group-card'
import type { Group } from '@/types/database'

export default async function DashboardPage() {
  const supabase = await createClient()

  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/')

  const { data: memberships } = await supabase
    .from('group_members')
    .select(`
      group_id,
      groups (
        id, name, photo_url, invite_code, owner_id, created_at
      )
    `)
    .eq('user_id', user.id)
    .order('joined_at', { ascending: false }) as any

  const groups = (memberships ?? [])
    .map((m: any) => m.groups)
    .filter(Boolean) as Group[]

  return (
    <main className="min-h-screen bg-[#0C0C0C] px-4 pt-8 pb-24 max-w-lg mx-auto">
      <div className="flex items-center justify-between mb-8">
        <div>
          <div className="font-black text-2xl tracking-tighter text-white leading-none">
            PRODE<span className="text-[#F5A623]">26</span>
          </div>
          <p className="text-[#555] text-xs mt-0.5">Mundial 2026</p>
        </div>
        <SignOutButton />
      </div>

      <section>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-white font-semibold text-base">Mis grupos</h2>
          <Link href="/crear-grupo">
            <Button
              size="sm"
              className="bg-[#F5A623] text-black font-semibold text-xs h-8 hover:bg-[#E8981A]"
            >
              + Nuevo
            </Button>
          </Link>
        </div>

        {groups.length === 0 ? (
          <div className="text-center py-12">
            <div className="text-4xl mb-3">⚽</div>
            <p className="text-[#888] text-sm font-medium mb-1">Todavía no tenés grupos</p>
            <p className="text-[#555] text-xs mb-4">
              Creá uno e invitá a tu gente antes del 11 de junio.
            </p>
            <Link href="/crear-grupo">
              <Button className="bg-[#F5A623] text-black font-semibold hover:bg-[#E8981A] h-10 text-sm">
                Crear mi primer grupo
              </Button>
            </Link>
          </div>
        ) : (
          <div className="flex flex-col gap-3">
            {groups.map(group => (
              <GroupCard key={group.id} group={group} userId={user.id} />
            ))}
          </div>
        )}
      </section>

      <div className="mt-8 rounded-xl bg-[#161616] border border-[#262626] p-4">
        <p className="text-[#F5A623] text-xs font-semibold uppercase tracking-wider mb-1">
          11 de junio · Apertura
        </p>
        <p className="text-white text-sm font-medium">
          México vs Sudáfrica · Estadio Azteca
        </p>
        <p className="text-[#555] text-xs mt-1">
          Las predicciones cierran al inicio del partido.
        </p>
      </div>
    </main>
  )
}
