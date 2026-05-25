import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get('code');
  const next = searchParams.get('next') ?? '/dashboard';

  if (!code) {
    return NextResponse.redirect(`${origin}/?error=missing_code`);
  }

  const supabase = await createClient();

  const { error: exchangeError } = await supabase.auth.exchangeCodeForSession(code);

  if (exchangeError) {
    console.error('Code exchange error:', exchangeError);
    return NextResponse.redirect(`${origin}/?error=auth_failed`);
  }

  // Crear profile si es la primera vez que entra el usuario
  const { data: { user } } = await supabase.auth.getUser();

  if (user) {
    const { data: existingProfile } = await supabase
      .from('profiles')
      .select('id')
      .eq('id', user.id)
      .maybeSingle();

    if (!existingProfile) {
      const displayName = user.email?.split('@')[0] ?? 'Usuario';

      const { error: profileError } = await supabase
        .from('profiles')
        .insert({
          id: user.id,
          display_name: displayName,
          preferred_locale: 'es',
        });

      if (profileError) {
        console.error('Profile creation error:', profileError);
        // No bloqueamos el login — se puede reintentar después
      }
    }
  }

  return NextResponse.redirect(`${origin}${next}`);
}