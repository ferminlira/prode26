'use client'

// components/groups/join-group-button.tsx

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'

interface Props {
  inviteCode: string
  groupId: string
  isLoggedIn: boolean
}

export function JoinGroupButton({ inviteCode, groupId, isLoggedIn }: Props) {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  async function handleJoin() {
    setLoading(true)
    setError(null)

    const supabase = createClient()

    // Si no está logueado, guardar el invite en sessionStorage y redirigir al login
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      sessionStorage.setItem('pending_invite', inviteCode)
      router.push('/')
      return
    }

    const { error: memberError } = await supabase
      .from('group_members')
      .insert({
        group_id: groupId,
        user_id: user.id,
      })

    if (memberError) {
      if (memberError.code === '23505') {
        // Ya es miembro (unique constraint)
        router.push(`/grupo/${groupId}`)
        return
      }
      setError('No se pudo unir al grupo. Intentá de nuevo.')
      setLoading(false)
      return
    }

    router.push(`/grupo/${groupId}`)
  }

  return (
    <div>
      <Button
        onClick={handleJoin}
        disabled={loading}
        className="w-full bg-[#F5A623] text-black font-semibold h-12 hover:bg-[#E8981A] disabled:opacity-40 text-sm"
      >
        {loading
          ? 'Uniéndose...'
          : isLoggedIn
          ? 'Unirme al grupo →'
          : 'Entrar para unirme →'
        }
      </Button>

      {error && (
        <p className="text-red-400 text-xs text-center mt-2">{error}</p>
      )}

      {!isLoggedIn && (
        <p className="text-[#555] text-xs text-center mt-2">
          Vas a tener que loguearte primero.
        </p>
      )}
    </div>
  )
}
