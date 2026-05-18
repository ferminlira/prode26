'use client'

// components/auth/sign-out-button.tsx

import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'

export function SignOutButton() {
  const router = useRouter()

  async function handleSignOut() {
    const supabase = createClient()
    await supabase.auth.signOut()
    router.push('/')
  }

  return (
    <button
      onClick={handleSignOut}
      className="text-[#555] text-xs hover:text-[#888] transition-colors"
    >
      Salir
    </button>
  )
}
