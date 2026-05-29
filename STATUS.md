# Prode26 — Status actual

**Última actualización**: cierre de Sesión 3 + decisiones de onboarding documentadas

## Qué funciona

- ✅ Repo en GitHub (https://github.com/ferminlira/prode26)
- ✅ Deploy en Vercel (https://prode26-rose.vercel.app)
- ✅ Supabase project con schema completo
- ✅ 48 equipos seeded en `teams`
- ✅ 72 partidos de fase de grupos seeded en `matches`
- ✅ Env vars correctamente cargadas en Vercel
- ✅ Login con magic link end-to-end
- ✅ Creación automática de `profile` al primer login
- ✅ Crear grupo funciona end-to-end (nombre + penalty_text → redirect al detalle)
- ✅ Detalle de grupo (`/grupo/[id]`) carga correctamente con miembros
- ✅ Link de invitación visible en el detalle del grupo
- ✅ `types/database.ts` regenerado con Supabase CLI — tipado sincronizado con el schema real
- ✅ Sin `as never` workarounds en el codebase

## Bugs resueltos en Sesión 3

- `owner_id` → `created_by` en la query del dashboard (causaba 500 al cargar grupos)
- Recursión infinita en RLS de `group_members` — fix con función `get_my_group_ids()` SECURITY DEFINER
- `role: 'admin'` → `'owner'` en el insert de `group_members` al crear grupo
- Policy `groups: creator read` para que el RETURNING post-INSERT funcione
- FK `group_members.user_id` → `profiles.id` para habilitar el select anidado de PostgREST
- Perfil faltante del usuario de debug creado manualmente

## Qué está roto

- 🔴 **`pending_invite` flow**: el invite_code se pasa por sessionStorage pero nada lo recupera post-login para auto-joinear al grupo. Fix propuesto: pasar el invite por query param `?next=/invite/[code]` en el redirect al login, y que el callback redirija ahí post-auth.
- 🟡 **Rate limit de mails de Supabase**: ~3-4/hora en free tier. Bloqueante para launch, no para desarrollo. Fix: configurar Resend en Supabase → Authentication → SMTP Settings.
- 🟡 **Perfil de usuario de debug**: creado manualmente. Nuevos usuarios crean su perfil automáticamente vía callback — verificar con un usuario nuevo en incógnito.

## Próximos tasks (Sesión 4)

En este orden:

1. **Fix `pending_invite`** — pasar invite por query param, recuperar en callback, auto-join
2. **Pantalla `/grupo/[id]/predecir`** — 72 partidos agrupados por jornada, inputs de score, upsert con debounce
3. **(Si queda tiempo)** Cálculo de puntos post-partido

## Para el next chat de implementación

Llenar el `handoff-sonnet.md` con:
- Task 1: fix pending_invite
- Task 2: pantalla de predicciones
- Restricción de tiempo: 7 hs
- Prioridad: pending_invite es rápido (1 hs), predicciones es el grueso

## Para el next chat estratégico

Posibles temas para Opus:
- Diseño visual de la representación de países (sin mapamundi, sin estereotipo)
- Estrategia de viralización pre-launch (primeros 100 grupos)
- Naming y branding final
- ~~Onboarding — flows y decisiones~~ ✅ Documentado en `ROADMAP.md`