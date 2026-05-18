-- =============================================================
-- supabase/rls.sql — Prode26
-- Row Level Security: políticas mínimas para v1
--
-- Ejecutar en el SQL editor de Supabase (como owner del schema).
-- Idempotente: DROP IF EXISTS antes de cada CREATE.
--
-- Resumen de acceso:
--   teams, matches  → lectura pública (anon + auth)
--   profiles        → cada user gestiona el suyo; compañeros de
--                     grupo ven solo display_name y avatar_url
--   groups          → insert libre (auth); update solo owner
--   group_members   → lectura + insert para miembros del grupo
--   predictions     → lectura por grupo; write solo del dueño;
--                     bloqueo de update post-kickoff en la DB
-- =============================================================


-- Habilitar RLS en todas las tablas
ALTER TABLE profiles       ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups         ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members  ENABLE ROW LEVEL SECURITY;
ALTER TABLE teams          ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches        ENABLE ROW LEVEL SECURITY;
ALTER TABLE predictions    ENABLE ROW LEVEL SECURITY;


-- =============================================================
-- teams — solo lectura, pública
-- Los equipos son datos de referencia globales. Los necesita
-- ver cualquiera (incluso sin login) para renderizar el fixture.
-- =============================================================
DROP POLICY IF EXISTS "teams_select_public" ON teams;
CREATE POLICY "teams_select_public"
  ON teams FOR SELECT USING (true);


-- =============================================================
-- matches — solo lectura, pública
-- Mismo razonamiento que teams. El fixture debe verse antes de
-- que el usuario se loguee (ej: llega por un invite link).
-- =============================================================
DROP POLICY IF EXISTS "matches_select_public" ON matches;
CREATE POLICY "matches_select_public"
  ON matches FOR SELECT USING (true);


-- =============================================================
-- profiles
-- =============================================================
DROP POLICY IF EXISTS "profiles_select_own"         ON profiles;
DROP POLICY IF EXISTS "profiles_select_group_peers"  ON profiles;
DROP POLICY IF EXISTS "profiles_insert_own"          ON profiles;
DROP POLICY IF EXISTS "profiles_update_own"          ON profiles;

-- El user puede leer su propio perfil completo
CREATE POLICY "profiles_select_own"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Compañeros de grupo pueden ver el perfil (para mostrar avatares
-- y nombres en la tabla de posiciones).
-- IMPORTANTE: en el cliente, consultar solo display_name y avatar_url,
-- no campos sensibles. Postgres RLS no filtra por columna; eso se
-- controla a nivel de query / view.
CREATE POLICY "profiles_select_group_peers"
  ON profiles FOR SELECT
  USING (
    id IN (
      SELECT gm.user_id
      FROM group_members gm
      WHERE gm.group_id IN (
        SELECT group_id FROM group_members WHERE user_id = auth.uid()
      )
    )
  );

CREATE POLICY "profiles_insert_own"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update_own"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);


-- =============================================================
-- groups
-- Asume columna owner_id UUID. Ajustá si tu schema usa created_by.
-- =============================================================
DROP POLICY IF EXISTS "groups_select_members" ON groups;
DROP POLICY IF EXISTS "groups_insert_auth"    ON groups;
DROP POLICY IF EXISTS "groups_update_owner"   ON groups;

-- Solo miembros del grupo pueden verlo
CREATE POLICY "groups_select_members"
  ON groups FOR SELECT
  USING (
    id IN (
      SELECT group_id FROM group_members WHERE user_id = auth.uid()
    )
  );

-- Cualquier usuario autenticado puede crear un grupo
CREATE POLICY "groups_insert_auth"
  ON groups FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- Solo el owner puede editar el grupo (nombre, foto, tema)
CREATE POLICY "groups_update_owner"
  ON groups FOR UPDATE
  USING (auth.uid() = owner_id);


-- =============================================================
-- group_members
-- =============================================================
DROP POLICY IF EXISTS "group_members_select_peers" ON group_members;
DROP POLICY IF EXISTS "group_members_insert_self"  ON group_members;

-- Miembros del grupo ven quiénes más están en él
CREATE POLICY "group_members_select_peers"
  ON group_members FOR SELECT
  USING (
    group_id IN (
      SELECT group_id FROM group_members WHERE user_id = auth.uid()
    )
  );

-- Un user autenticado puede unirse a un grupo (insertarse a sí mismo).
-- La validación del invite_code se hace en la ruta /invite/[code];
-- aquí solo controlamos que el user_id del row sea el del caller.
CREATE POLICY "group_members_insert_self"
  ON group_members FOR INSERT
  WITH CHECK (auth.uid() = user_id);


-- =============================================================
-- predictions
--
-- La política de update es la más importante del sistema:
-- bloquea cualquier modificación una vez que arrancó el partido.
-- Esto se enforcea EN LA BASE DE DATOS, no solo en el frontend,
-- así que no importa si alguien hace una llamada directa a la API.
-- =============================================================
DROP POLICY IF EXISTS "predictions_select_group" ON predictions;
DROP POLICY IF EXISTS "predictions_insert_own"   ON predictions;
DROP POLICY IF EXISTS "predictions_update_own"   ON predictions;

-- Miembros del grupo pueden ver las predicciones de todos en el grupo
CREATE POLICY "predictions_select_group"
  ON predictions FOR SELECT
  USING (
    group_id IN (
      SELECT group_id FROM group_members WHERE user_id = auth.uid()
    )
  );

-- Solo el user puede crear su propia predicción
CREATE POLICY "predictions_insert_own"
  ON predictions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- El user puede actualizar su predicción SOLO antes del kickoff.
-- Una vez que matches.kickoff_at <= now(), la DB rechaza el update
-- aunque el cliente lo intente mandar. No hay escape.
CREATE POLICY "predictions_update_own"
  ON predictions FOR UPDATE
  USING (
    auth.uid() = user_id
    AND (
      SELECT kickoff_at FROM matches WHERE id = predictions.match_id
    ) > now()
  );

-- Sin DELETE policy en ninguna tabla de usuario → nadie borra datos
