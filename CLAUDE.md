# Prode26 — Project Context

A web-based prediction game for the 2026 FIFA World Cup. Small groups (office, friends, family) compete by predicting match scores. Single developer, ~7 hrs/week, MVP target: 11 June 2026.

This file is the source of truth on stack, schema, and conventions for AI coding agents working on this repository. Read also `ROADMAP.md` for product vision and `STATUS.md` for current state.

## Resources

- Deployed app: https://prode26-rose.vercel.app
- Repository: https://github.com/ferminlira/prode26
- Supabase project: https://lectnqnimblopucxsncv.supabase.co

## Tech Stack

- Next.js (App Router) + TypeScript, project uses `src/` directory structure
- Supabase (Postgres, Auth, Realtime, Storage) via `@supabase/ssr`
- Tailwind CSS + shadcn/ui
- Vercel for hosting
- next-intl planned for i18n (not yet installed)

## Project Structure

```
src/
  app/                            Routes (App Router)
    page.tsx                      Login (magic link via signInWithOtp)
    auth/callback/route.ts        Supabase auth callback, exchanges code for session, creates profile on first login
    dashboard/page.tsx            User's groups list
    crear-grupo/page.tsx          Group creation form (currently broken with 500 — see Known Issues)
    grupo/[id]/page.tsx           Group detail + invite link + members
    invite/[code]/page.tsx        Group preview + join button
  components/
    auth/sign-out-button.tsx
    groups/group-card.tsx
    groups/copy-invite-link-button.tsx
    groups/join-group-button.tsx
  lib/supabase/
    client.ts                     Browser client
    server.ts                     Server client (async, cookies-based)
  types/database.ts               Schema types — INCOMPLETE, see tech debt
  proxy.ts                        Middleware logic (silent failure on Vercel — do not modify)
middleware.ts                     Edge middleware entry, delegates to src/proxy.ts
supabase/
  seed.sql                        Idempotent seed: 48 teams + 72 matches
  rls.sql                         RLS policies (idempotent, MAY BE INCOMPLETE — see Known Issues)
  migrations/add_missing_columns.sql
  functions/get_group_preview.sql
```

## Database Schema

Use exact column names below. Do not invent variants.

**profiles** — id (uuid → auth.users), display_name, avatar_url, preferred_locale, created_at

**groups** — id (uuid), name, photo_url, theme, invite_code, created_by (uuid), created_at, penalty_text (nullable)

**group_members** — group_id (uuid), user_id (uuid), role ('owner' | 'member'), joined_at, score (int default 0)

**teams** — id (TEXT — FIFA code: 'MEX', 'ARG'), name_es, name_en, group_letter (A–L), flag_emoji

**matches** — id (TEXT — 'M01'…'M72'), stage, group_letter, home_team_id (TEXT → teams.id), away_team_id (TEXT → teams.id), kickoff_at, venue, city, home_score, away_score, status, created_at

**predictions** — id (uuid), user_id, group_id, match_id (TEXT → matches.id), predicted_home_score, predicted_away_score, points, locked_at, updated_at

**Schema gotchas (DO NOT change)**:

- `groups.created_by` — never `owner_id`
- `matches.home_team_id` / `away_team_id` — never `team_a_id` / `team_b_id`
- `matches.home_score` / `away_score` — never `score_a` / `score_b`
- `matches.venue` — never `stadium`
- `predictions.predicted_home_score` / `predicted_away_score` — never `score_a/b`
- `teams.id` is TEXT (FIFA code), never UUID

## World Cup 2026 Groups

```
A: MEX RSA KOR CZE    B: CAN BIH QAT SUI    C: BRA MAR HAI SCO
D: USA PAR AUS TUR    E: GER CUW CIV ECU    F: NED JPN SWE TUN
G: BEL EGY IRN NZL    H: ESP CPV KSA URU    I: FRA SEN IRQ NOR
J: ARG ALG AUT JOR    K: POR COD UZB COL    L: ENG CRO GHA PAN
```

## Code Conventions

- App Router. Server Components for data fetching; Client Components (`'use client'`) only for interactivity.
- Supabase browser client: `import { createClient } from '@/lib/supabase/client'`
- Supabase server client: `import { createClient } from '@/lib/supabase/server'` (async)
- Mobile-first in every component — size and lay out for narrow screens first, then enhance.
- Spanish only in v1. Internationalisation comes during the tournament.
- Product copy in Argentine Spanish register (`vos`, not `tú`); internal docs and code comments in British English.

## Visual Design Tokens

- Background: `#0C0C0C`
- Cards: `#161616`
- Borders: `#262626`
- Accent (amber): `#F5A623`
- Secondary text: `#888`

## Product Hard Rules

- No betting/gambling language. Never use "pozo", "premio en plata", "ganancia". Use "competencia", "orgullo".
- No world maps (mapamundi). Cartography carries colonial visual bias.
- No cultural stereotype shortcuts (mate, pizza, pyramids, dragons, sombreros, kilims).
- Multi-script typography (Latin, Arabic, Cyrillic, CJK) is a brand statement, never hidden behind a setting.
- Animal avatars apply to players, never to countries.
- Mobile-first always.

## Scoring System

- Exact score: 5 points
- Correct goal difference + correct winner: 3 points
- Correct winner only: 1 point
- Wrong: 0 points

## Environment Variables (required)

```
NEXT_PUBLIC_SUPABASE_URL=https://lectnqnimblopucxsncv.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...               # server-only, never NEXT_PUBLIC_
NEXT_PUBLIC_APP_URL=https://prode26-rose.vercel.app
```

## Commands

- `npm run dev` — local development
- `npm run build` — production build
- `npm run lint` — eslint
- `npm run start` — production server (after build)

## Known Issues & Tech Debt

### Bloqueantes inmediatos

- **🔴 500 al crear grupo (bug crítico para Sesión 3)**: POST a `/rest/v1/groups` devuelve 500 Internal Server Error desde producción. Hipótesis principal: falta policy de INSERT en `groups` y/o en `group_members` (mismo patrón que tuvimos con `profiles`), o hay un trigger que intenta el insert de owner en `group_members` sin `security definer` y choca con RLS. **Diagnóstico**: Supabase → Database → Logs → reproducir el error → leer el mensaje del Postgres. Resolver antes de empezar predicciones.

- **🔴 `pending_invite` flow roto**: `JoinGroupButton` guarda `invite_code` en `sessionStorage` cuando el usuario no está logueado, pero nada lo recupera después del callback para auto-joinear el grupo. Una solución posible: en el momento de redirigir al login, pasar el invite por query param (`?next=/invite/[code]`) y que el callback redirija ahí post-auth.

- **🔴 SMTP propio antes del launch**: Supabase Auth free tier limita a ~3-4 mails/hora. Bloqueante para 11/06. Configurar Resend (free 3K/mes) en Supabase → Authentication → SMTP Settings.

### Tech debt

- **`types/database.ts` desincronizado del schema real**: la tabla `profiles` (y probablemente otras) no expone los tipos correctos de `Insert/Update`, forzando `as never` en mutations. Regenerar con Supabase CLI:
  ```bash
  npx supabase login
  npx supabase gen types typescript --project-id lectnqnimblopucxsncv > [path/to/database.ts]
  ```
  Verificar el path real con `find . -name database.ts -not -path "./node_modules/*"`. Después de regenerar, eliminar todos los `as never` usados como workaround.

- **Middleware (`src/proxy.ts`)**: wrapped en try/catch y silenciosamente falla en Vercel. Las redirecciones desde middleware no funcionan en producción; solo funcionan desde Server Components. No modificar.

- **`src/app/dashboard/page.tsx`**: usa `any` para el tipo del join de Supabase. Mejorar con tipos precisos cuando se regeneren los tipos.

- **Kickoff times del seed**: aproximados (±1h posible). Verificar contra FIFA.com antes del 11/06 y hacer `UPDATE` si necesario.

- **Templates de mail de Supabase en inglés**: cuando se prioritice UX, customizar subject y body en español argentino (Authentication → Email Templates).

## Sessions Log

- **Sesión 1**: Repo + Next.js + Vercel + Supabase project + initial schema + scoring system confirmado.
- **Sesión 2**: 48 teams + 72 matches seeded; RLS policies en algunas tablas; login (magic link), dashboard, crear grupo, invite link, invite acceptance flow — el código se escribió pero el archivo del callback nunca se commiteó al repo.
- **Sesión 2.5 (rescate)**: Re-creación de env vars en Vercel; creación del archivo faltante `src/app/auth/callback/route.ts`; fix de error de TypeScript con `as never`; policy de INSERT para `profiles`; diagnóstico de rate limit de email; confirmación end-to-end de auth en producción.
- **Sesión 3 (next)**: Fix del bug 500 de creación de grupo, fix de `pending_invite`, regeneración de tipos, y construcción de la pantalla de predicciones (`/grupo/[id]/predecir`).

## How to Work with the Owner (Fermín)

- Spanish, Argentine register (`vos`, not `tú`).
- Be opinionated and decisive — no menus of options.
- Provide complete code ready to paste; never pseudocode.
- Mobile-first in code and in response format (short, scannable).
- Frontend dev strong on UI; backend / DB / auth is a learning area — explain architectural "why", not just "what".
- Time budget: ~7 hrs/week.
- Hold the line on product hard rules and core values: cercanía, encuentro, memoria.
