-- supabase/functions/get_group_preview.sql
-- Función RPC que devuelve datos básicos de un grupo dado su invite_code
-- Se puede llamar desde el cliente anon sin ser miembro del grupo
-- SECURITY DEFINER: corre con permisos del owner (postgres), bypassea RLS
-- solo para esta función específica — no expone datos sensibles

-- Por qué SECURITY DEFINER y no cambiar la policy de SELECT en groups:
-- La policy "groups: member read" existe para que grupos privados no sean
-- visibles a no-miembros. Pero la landing de invitación necesita mostrar
-- el nombre y miembros del grupo para que el invitado sepa a qué se está
-- uniendo. En lugar de abrir toda la tabla, esta función devuelve
-- únicamente los campos necesarios para el preview, nada más.

CREATE OR REPLACE FUNCTION get_group_preview(p_invite_code TEXT)
RETURNS TABLE (
  group_id    UUID,
  group_name  TEXT,
  member_count BIGINT,
  penalty_text TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    g.id           AS group_id,
    g.name         AS group_name,
    COUNT(gm.id)   AS member_count,
    g.penalty_text
  FROM groups g
  LEFT JOIN group_members gm ON gm.group_id = g.id
  WHERE g.invite_code = p_invite_code
  GROUP BY g.id, g.name, g.penalty_text;
END;
$$;

-- Dar permiso a anon y authenticated para llamar la función
GRANT EXECUTE ON FUNCTION get_group_preview(TEXT) TO anon, authenticated;
