// lib/supabase/server.ts
// Cliente para usar en Server Components, Route Handlers y Server Actions
// Lee cookies de Next.js — no cachear entre requests

import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'
import type { Database } from '@/types/database'

export async function createClient() {
  const cookieStore = await cookies()

  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) => {
              cookieStore.set(name, value, options)
            })
          } catch {
            // setAll se llama desde un Server Component — no se pueden setear cookies
            // desde ahí. Si tenés middleware refreshando sesiones, esto es seguro ignorar.
          }
        },
      },
    }
  )
}
