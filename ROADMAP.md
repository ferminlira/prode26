# Prode26 — Roadmap

Vista estratégica del proyecto. Para referencia técnica detallada del código, ver `CLAUDE.md`. Para estado del trabajo en curso, ver `STATUS.md`.

## Visión

Prode26 es un objeto cultural envuelto en mecánica de prode. El Mundial 2026 es la excusa para que un grupo chico (oficina, amigos, familia) se reúna durante 39 días y al final tenga un recuerdo emocional compartido. No es un prode genérico ni un leaderboard global anónimo — es una herramienta de cercanía.

Diseñado desde Argentina (país de inmigrantes, sur global) para el mundo. Tiene que resonar con culturas árabe, asiática, africana, latinoamericana y anglo sin caer en el default cultural blanco occidental.

## Tres palancas (no negociables)

- **Cercanía** — el grupo chico es el centro. Nunca un leaderboard global anónimo.
- **Encuentro** — el Mundial como reunión entre culturas, no como guerra entre naciones.
- **Memoria** — al final del torneo queda algo lindo para guardar.

## Reglas duras

- Sin lenguaje de apuestas (nunca "pozo", "premio en plata"). Es competencia y orgullo.
- Sin mapamundi (cartografía heredera del colonialismo visual).
- Sin estereotipos shortcut (mate, pizza, pirámides, dragones, sombreros, kilims).
- Tipografía multi-script como statement de marca: latín, árabe, cirílico, CJK conviven.
- Avatares animales se aplican al jugador, no al país.
- Mobile-first siempre.

## Alcance del MVP — Launch 11 de junio 2026

**Entra**:
- Auth (magic link)
- Crear grupo (foto + nombre + tema + penalty_text en joda)
- Link de invitación universal
- Predicciones de fase de grupos (48 equipos / 12 grupos / 72 partidos)
- Tabla de posiciones del grupo
- Imagen compartible básica del ranking (vía @vercel/og)
- Sólo en español

**Sale durante el torneo (releases semanales)**:
- Semana 1: inglés y portugués
- Semana 2: predicciones de Ronda de 32 (cuando termine fase de grupos)
- Semana 3: diseño sonoro, cards compartibles pulidas
- Semana 4: árabe y francés
- Cierre: "momento trofeo" del ganador (estilo Spotify Wrapped del Mundial)

**No entra en v1**:
- Pago (todo gratis en v1, monetización va a v2)
- Chat dentro de la app (WhatsApp es el chat, la app genera contenido para tirar ahí)
- App nativa (PWA mobile-first alcanza para v1)

## Idiomas por prioridad

1. ES (v1)
2. EN, PT (v1.1)
3. AR, FR (v1.2)
4. DE, IT (backlog)

**No se incluye**: ruso (Rusia banneada del Mundial 2026), chino (China no clasificó).

## Mecánica de predicciones

Híbrida por etapa:
- **Fase de grupos**: todas las predicciones se cargan de una vez antes del 11/06. Crea el pico social inicial.
- **Knockouts**: se desbloquean a medida que terminan las fases anteriores. Crea re-engagement durante el torneo.

Sistema de puntos:
- Resultado exacto: 5 pts
- Diferencia + ganador correctos: 3 pts
- Sólo ganador correcto: 1 pt
- Errado: 0 pts

## Engagement durante 39 días

- **Web push notifications** como canal principal (no email).
- Permiso de push se pide DESPUÉS de las primeras predicciones, jamás en el primer visit.
- Email opcional, baja frecuencia (recap semanal).
- **WhatsApp es el chat** — la app no tiene chat propio, genera contenido (imágenes del ranking) para que se tire ahí.
- Cadencia de push: 24hs antes de partidos sin predicción, 1hr antes (último llamado), post-partido (resumen rápido).

## Premio implícito

Bragging rights documentados. Al crear grupo se pide el `penalty_text` (qué tiene que hacer el último puesto, en joda). Queda guardado y se les recuerda al final.

El ganador recibe un "momento trofeo" generado al cierre — imagen/video corto compartible, estilo Spotify Wrapped del Mundial.

## Estado actual (alto nivel)

Para detalle del estado de la última sesión, ver `STATUS.md`. Resumen:

- ✅ Infra: repo, Vercel, Supabase, env vars, schema, seed
- ✅ Auth funcionando end-to-end en producción
- 🔴 Bug crítico: 500 al crear grupo (bloqueante para Sesión 3)
- ⏳ Pendientes: predicciones, leaderboard, imagen compartible, SMTP propio
- 📅 Faltan 5 semanas hasta el 11/06

## Sesiones por delante (estimado)

- **Sesión 3** — Fix bugs de Sesión 2 + pantalla de predicciones (`/grupo/[id]/predecir`)
- **Sesión 4** — Cálculo de puntos + leaderboard del grupo
- **Sesión 5** — Imagen compartible básica con @vercel/og
- **Sesión 6** — SMTP propio (Resend), polish UX del login, fix `pending_invite`
- **Sesión 7** — Buffer / polish / mobile testing real
- **Sesión 8 (último finde antes del 11/06)** — verificación final, datos del fixture contra FIFA, deploy

Cada sesión ~7 hs. Total ~50 hs antes del launch. Algo se va a recortar.

## Pricing strategy

**v1 (Mundial 2026)**: gratis total. Sin Stripe, sin pagos. Construir audiencia primero.

**v2 (próximo torneo, Copa América / Eurocopa / Mundial femenino)**: modelo "pagás el grupo, no el usuario". Una persona del grupo paga ~USD 3-5 una vez y desbloquea features para todos (trofeo premium, sound pack, stats avanzadas, sin ads). Convierte presión social en algo positivo.

## Budget realista

- **Antes de launch**: USD 10-15 (dominio si se compra). Resto en free tiers.
- **Mid-launch (si pega)**: USD 25-50/mes (Supabase Pro, posible API de fútbol pago).
- **Pico viral**: USD 75-150/mes (Vercel upgrade, mejor SMTP).

## Decisiones estratégicas abiertas (para chats con Opus)

- Nombre y branding final (hoy "Prode26" provisorio)
- Dominio real (hoy `prode26-rose.vercel.app` provisorio)
- Diseño visual de la representación de países (sin estereotipo, sin mapamundi)
- Cómo presentar la tipografía multi-script como marca
- Estrategia de viralización pre-launch (memes, tendencias)
- API de fútbol a usar para resultados en vivo durante el torneo
