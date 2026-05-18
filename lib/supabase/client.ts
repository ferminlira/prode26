// lib/supabase/client.ts
// Cliente para usar en Client Components (browser)
// Usa @supabase/ssr — no usar @supabase/supabase-js directamente en componentes

import { createBrowserClient } from '@supabase/ssr'
import type { Database } from '@/types/database'

export function createClient() {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
