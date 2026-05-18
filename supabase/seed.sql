-- =============================================================
-- supabase/seed.sql — Prode26
-- Equipos (48) + partidos de fase de grupos (72) — Mundial 2026
--
-- Fuente: FIFA / worldcupwiki.com (verificado 17 mayo 2026)
-- Playoffs confirmados el 31 de marzo 2026
--
-- Horarios en UTC. El torneo corre en EDT (UTC-4).
-- Conversión: hora ET + 4 = hora UTC.
--
-- ASUNCIONES DE SCHEMA — ajustá si tus columnas difieren:
--   teams:   id UUID, name TEXT, country_code VARCHAR(3),
--            group_letter CHAR(1)
--   matches: id UUID, home_team_id UUID, away_team_id UUID,
--            group_letter CHAR(1), stage TEXT,
--            kickoff_at TIMESTAMPTZ, venue TEXT, city TEXT
--
-- IDEMPOTENTE: TRUNCATE al inicio.
-- Seguro mientras no haya predictions en DB.
-- Si ya hay predictions, comentá los TRUNCATE y agregá
-- ON CONFLICT (id) DO NOTHING a cada INSERT.
-- =============================================================

BEGIN;

-- Limpieza de datos de seed previos
TRUNCATE TABLE matches CASCADE;
TRUNCATE TABLE teams CASCADE;


-- =============================================================
-- EQUIPOS — 48 equipos, grupos A–L
--
-- IDs deterministas con formato '00000000-0000-0000-0000-0000000000XX'
-- para poder referenciarlos directamente en el INSERT de matches.
--
-- country_code: ISO 3166-1 alpha-2 salvo Inglaterra (ENG) y
-- Escocia (SCO) que usan códigos FIFA porque no tienen ISO propio.
-- Requiere que la columna sea VARCHAR, no CHAR(2).
-- =============================================================

INSERT INTO teams (id, name, country_code, group_letter) VALUES
  -- Grupo A
  ('00000000-0000-0000-0000-000000000001', 'Mexico',                    'MX',  'A'),
  ('00000000-0000-0000-0000-000000000002', 'Sudafrica',                 'ZA',  'A'),
  ('00000000-0000-0000-0000-000000000003', 'Corea del Sur',             'KR',  'A'),
  ('00000000-0000-0000-0000-000000000004', 'Chequia',                   'CZ',  'A'),
  -- Grupo B
  ('00000000-0000-0000-0000-000000000005', 'Canada',                    'CA',  'B'),
  ('00000000-0000-0000-0000-000000000006', 'Bosnia y Herzegovina',      'BA',  'B'),
  ('00000000-0000-0000-0000-000000000007', 'Qatar',                     'QA',  'B'),
  ('00000000-0000-0000-0000-000000000008', 'Suiza',                     'CH',  'B'),
  -- Grupo C
  ('00000000-0000-0000-0000-000000000009', 'Brasil',                    'BR',  'C'),
  ('00000000-0000-0000-0000-000000000010', 'Marruecos',                 'MA',  'C'),
  ('00000000-0000-0000-0000-000000000011', 'Haiti',                     'HT',  'C'),
  ('00000000-0000-0000-0000-000000000012', 'Escocia',                   'SCO', 'C'),
  -- Grupo D
  ('00000000-0000-0000-0000-000000000013', 'Estados Unidos',            'US',  'D'),
  ('00000000-0000-0000-0000-000000000014', 'Paraguay',                  'PY',  'D'),
  ('00000000-0000-0000-0000-000000000015', 'Australia',                 'AU',  'D'),
  ('00000000-0000-0000-0000-000000000016', 'Turkiye',                   'TR',  'D'),
  -- Grupo E
  ('00000000-0000-0000-0000-000000000017', 'Alemania',                  'DE',  'E'),
  ('00000000-0000-0000-0000-000000000018', 'Curazao',                   'CW',  'E'),
  ('00000000-0000-0000-0000-000000000019', 'Costa de Marfil',           'CI',  'E'),
  ('00000000-0000-0000-0000-000000000020', 'Ecuador',                   'EC',  'E'),
  -- Grupo F
  ('00000000-0000-0000-0000-000000000021', 'Paises Bajos',              'NL',  'F'),
  ('00000000-0000-0000-0000-000000000022', 'Japon',                     'JP',  'F'),
  ('00000000-0000-0000-0000-000000000023', 'Suecia',                    'SE',  'F'),
  ('00000000-0000-0000-0000-000000000024', 'Tunez',                     'TN',  'F'),
  -- Grupo G
  ('00000000-0000-0000-0000-000000000025', 'Belgica',                   'BE',  'G'),
  ('00000000-0000-0000-0000-000000000026', 'Egipto',                    'EG',  'G'),
  ('00000000-0000-0000-0000-000000000027', 'Iran',                      'IR',  'G'),
  ('00000000-0000-0000-0000-000000000028', 'Nueva Zelanda',             'NZ',  'G'),
  -- Grupo H
  ('00000000-0000-0000-0000-000000000029', 'Espana',                    'ES',  'H'),
  ('00000000-0000-0000-0000-000000000030', 'Cabo Verde',                'CV',  'H'),
  ('00000000-0000-0000-0000-000000000031', 'Arabia Saudita',            'SA',  'H'),
  ('00000000-0000-0000-0000-000000000032', 'Uruguay',                   'UY',  'H'),
  -- Grupo I (grupo de la muerte)
  ('00000000-0000-0000-0000-000000000033', 'Francia',                   'FR',  'I'),
  ('00000000-0000-0000-0000-000000000034', 'Senegal',                   'SN',  'I'),
  ('00000000-0000-0000-0000-000000000035', 'Noruega',                   'NO',  'I'),
  ('00000000-0000-0000-0000-000000000036', 'Irak',                      'IQ',  'I'),
  -- Grupo J
  ('00000000-0000-0000-0000-000000000037', 'Argentina',                 'AR',  'J'),
  ('00000000-0000-0000-0000-000000000038', 'Argelia',                   'DZ',  'J'),
  ('00000000-0000-0000-0000-000000000039', 'Austria',                   'AT',  'J'),
  ('00000000-0000-0000-0000-000000000040', 'Jordania',                  'JO',  'J'),
  -- Grupo K
  ('00000000-0000-0000-0000-000000000041', 'Portugal',                  'PT',  'K'),
  ('00000000-0000-0000-0000-000000000042', 'Rep. Dem. del Congo',       'CD',  'K'),
  ('00000000-0000-0000-0000-000000000043', 'Uzbekistan',                'UZ',  'K'),
  ('00000000-0000-0000-0000-000000000044', 'Colombia',                  'CO',  'K'),
  -- Grupo L
  ('00000000-0000-0000-0000-000000000045', 'Inglaterra',                'ENG', 'L'),
  ('00000000-0000-0000-0000-000000000046', 'Croacia',                   'HR',  'L'),
  ('00000000-0000-0000-0000-000000000047', 'Ghana',                     'GH',  'L'),
  ('00000000-0000-0000-0000-000000000048', 'Panama',                    'PA',  'L');


-- =============================================================
-- PARTIDOS — 72 partidos de fase de grupos
--
-- stage = 'group'  ← ajustá si tu schema usa otro valor
--
-- Referencia rápida de IDs:
--   A: MX=01 ZA=02 KR=03 CZ=04
--   B: CA=05 BA=06 QA=07 CH=08
--   C: BR=09 MA=10 HT=11 SCO=12
--   D: US=13 PY=14 AU=15 TR=16
--   E: DE=17 CW=18 CI=19 EC=20
--   F: NL=21 JP=22 SE=23 TN=24
--   G: BE=25 EG=26 IR=27 NZ=28
--   H: ES=29 CV=30 SA=31 UY=32
--   I: FR=33 SN=34 NO=35 IQ=36
--   J: AR=37 DZ=38 AT=39 JO=40
--   K: PT=41 CD=42 UZ=43 CO=44
--   L: ENG=45 HR=46 GH=47 PA=48
-- =============================================================

INSERT INTO matches (id, home_team_id, away_team_id, group_letter, stage, kickoff_at, venue, city)
VALUES

-- ===========================================================
-- JORNADA 1
-- ===========================================================

-- Jueves 11 jun
-- A | Mexico vs Sudafrica | 3:00 PM ET = 19:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002',
 'A', 'group', '2026-06-11T19:00:00Z', 'Estadio Azteca', 'Ciudad de Mexico'),

-- A | Corea del Sur vs Chequia | 10:00 PM ET = 02:00 UTC (jun 12)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000004',
 'A', 'group', '2026-06-12T02:00:00Z', 'Estadio Akron', 'Zapopan'),

-- Viernes 12 jun
-- B | Canada vs Bosnia y Herzegovina | 3:00 PM ET = 19:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000006',
 'B', 'group', '2026-06-12T19:00:00Z', 'BMO Field', 'Toronto'),

-- D | Estados Unidos vs Paraguay | 9:00 PM ET = 01:00 UTC (jun 13)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000013', '00000000-0000-0000-0000-000000000014',
 'D', 'group', '2026-06-13T01:00:00Z', 'SoFi Stadium', 'Inglewood'),

-- Sabado 13 jun
-- B | Qatar vs Suiza | 3:00 PM ET = 19:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000008',
 'B', 'group', '2026-06-13T19:00:00Z', 'Levis Stadium', 'Santa Clara'),

-- C | Brasil vs Marruecos | 6:00 PM ET = 22:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000010',
 'C', 'group', '2026-06-13T22:00:00Z', 'MetLife Stadium', 'East Rutherford'),

-- C | Haiti vs Escocia | 9:00 PM ET = 01:00 UTC (jun 14)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000012',
 'C', 'group', '2026-06-14T01:00:00Z', 'Gillette Stadium', 'Foxborough'),

-- Domingo 14 jun
-- D | Australia vs Turkiye | 12:00 AM ET = 04:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000015', '00000000-0000-0000-0000-000000000016',
 'D', 'group', '2026-06-14T04:00:00Z', 'BC Place', 'Vancouver'),

-- E | Alemania vs Curazao | 1:00 PM ET = 17:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000017', '00000000-0000-0000-0000-000000000018',
 'E', 'group', '2026-06-14T17:00:00Z', 'NRG Stadium', 'Houston'),

-- F | Paises Bajos vs Japon | 4:00 PM ET = 20:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000021', '00000000-0000-0000-0000-000000000022',
 'F', 'group', '2026-06-14T20:00:00Z', 'AT&T Stadium', 'Arlington'),

-- E | Costa de Marfil vs Ecuador | 7:00 PM ET = 23:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000019', '00000000-0000-0000-0000-000000000020',
 'E', 'group', '2026-06-14T23:00:00Z', 'Lincoln Financial Field', 'Filadelfia'),

-- F | Suecia vs Tunez | 10:00 PM ET = 02:00 UTC (jun 15)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000023', '00000000-0000-0000-0000-000000000024',
 'F', 'group', '2026-06-15T02:00:00Z', 'Estadio BBVA', 'Monterrey'),

-- Lunes 15 jun
-- H | Espana vs Cabo Verde | 12:00 PM ET = 16:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000029', '00000000-0000-0000-0000-000000000030',
 'H', 'group', '2026-06-15T16:00:00Z', 'Mercedes-Benz Stadium', 'Atlanta'),

-- G | Belgica vs Egipto | 3:00 PM ET = 19:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000025', '00000000-0000-0000-0000-000000000026',
 'G', 'group', '2026-06-15T19:00:00Z', 'Lumen Field', 'Seattle'),

-- H | Arabia Saudita vs Uruguay | 6:00 PM ET = 22:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000031', '00000000-0000-0000-0000-000000000032',
 'H', 'group', '2026-06-15T22:00:00Z', 'Hard Rock Stadium', 'Miami Gardens'),

-- G | Iran vs Nueva Zelanda | 9:00 PM ET = 01:00 UTC (jun 16)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000027', '00000000-0000-0000-0000-000000000028',
 'G', 'group', '2026-06-16T01:00:00Z', 'SoFi Stadium', 'Inglewood'),

-- Martes 16 jun
-- I | Francia vs Senegal | 3:00 PM ET = 19:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000033', '00000000-0000-0000-0000-000000000034',
 'I', 'group', '2026-06-16T19:00:00Z', 'MetLife Stadium', 'East Rutherford'),

-- I | Irak vs Noruega | 6:00 PM ET = 22:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000036', '00000000-0000-0000-0000-000000000035',
 'I', 'group', '2026-06-16T22:00:00Z', 'Gillette Stadium', 'Foxborough'),

-- J | Argentina vs Argelia | 9:00 PM ET = 01:00 UTC (jun 17)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000037', '00000000-0000-0000-0000-000000000038',
 'J', 'group', '2026-06-17T01:00:00Z', 'Arrowhead Stadium', 'Kansas City'),

-- Miercoles 17 jun
-- J | Austria vs Jordania | 12:00 AM ET = 04:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000039', '00000000-0000-0000-0000-000000000040',
 'J', 'group', '2026-06-17T04:00:00Z', 'Levis Stadium', 'Santa Clara'),

-- K | Portugal vs Rep. Dem. del Congo | 1:00 PM ET = 17:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000041', '00000000-0000-0000-0000-000000000042',
 'K', 'group', '2026-06-17T17:00:00Z', 'NRG Stadium', 'Houston'),

-- L | Inglaterra vs Croacia | 4:00 PM ET = 20:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000045', '00000000-0000-0000-0000-000000000046',
 'L', 'group', '2026-06-17T20:00:00Z', 'AT&T Stadium', 'Arlington'),

-- L | Ghana vs Panama | 7:00 PM ET = 23:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000047', '00000000-0000-0000-0000-000000000048',
 'L', 'group', '2026-06-17T23:00:00Z', 'BMO Field', 'Toronto'),

-- K | Uzbekistan vs Colombia | 10:00 PM ET = 02:00 UTC (jun 18)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000043', '00000000-0000-0000-0000-000000000044',
 'K', 'group', '2026-06-18T02:00:00Z', 'Estadio Azteca', 'Ciudad de Mexico'),


-- ===========================================================
-- JORNADA 2
-- ===========================================================

-- Jueves 18 jun
-- A | Chequia vs Sudafrica | 12:00 PM ET = 16:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000002',
 'A', 'group', '2026-06-18T16:00:00Z', 'Mercedes-Benz Stadium', 'Atlanta'),

-- B | Suiza vs Bosnia y Herzegovina | 3:00 PM ET = 19:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000006',
 'B', 'group', '2026-06-18T19:00:00Z', 'SoFi Stadium', 'Inglewood'),

-- B | Canada vs Qatar | 6:00 PM ET = 22:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000007',
 'B', 'group', '2026-06-18T22:00:00Z', 'BC Place', 'Vancouver'),

-- A | Mexico vs Corea del Sur | 9:00 PM ET = 01:00 UTC (jun 19)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003',
 'A', 'group', '2026-06-19T01:00:00Z', 'Estadio Akron', 'Zapopan'),

-- Viernes 19 jun
-- D | Estados Unidos vs Australia | 3:00 PM ET = 19:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000013', '00000000-0000-0000-0000-000000000015',
 'D', 'group', '2026-06-19T19:00:00Z', 'Lumen Field', 'Seattle'),

-- C | Escocia vs Marruecos | 6:00 PM ET = 22:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000010',
 'C', 'group', '2026-06-19T22:00:00Z', 'Gillette Stadium', 'Foxborough'),

-- C | Brasil vs Haiti | 8:30 PM ET = 00:30 UTC (jun 20) ← unico con :30
(gen_random_uuid(), '00000000-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000011',
 'C', 'group', '2026-06-20T00:30:00Z', 'Lincoln Financial Field', 'Filadelfia'),

-- D | Turkiye vs Paraguay | 11:00 PM ET = 03:00 UTC (jun 20)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000016', '00000000-0000-0000-0000-000000000014',
 'D', 'group', '2026-06-20T03:00:00Z', 'Levis Stadium', 'Santa Clara'),

-- Sabado 20 jun
-- F | Paises Bajos vs Suecia | 1:00 PM ET = 17:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000021', '00000000-0000-0000-0000-000000000023',
 'F', 'group', '2026-06-20T17:00:00Z', 'NRG Stadium', 'Houston'),

-- E | Alemania vs Costa de Marfil | 4:00 PM ET = 20:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000017', '00000000-0000-0000-0000-000000000019',
 'E', 'group', '2026-06-20T20:00:00Z', 'BMO Field', 'Toronto'),

-- E | Ecuador vs Curazao | 8:00 PM ET = 00:00 UTC (jun 21)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000020', '00000000-0000-0000-0000-000000000018',
 'E', 'group', '2026-06-21T00:00:00Z', 'Arrowhead Stadium', 'Kansas City'),

-- Domingo 21 jun
-- F | Tunez vs Japon | 12:00 AM ET = 04:00 UTC (partido 1000 del Mundial)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000024', '00000000-0000-0000-0000-000000000022',
 'F', 'group', '2026-06-21T04:00:00Z', 'Estadio BBVA', 'Monterrey'),

-- H | Espana vs Arabia Saudita | 12:00 PM ET = 16:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000029', '00000000-0000-0000-0000-000000000031',
 'H', 'group', '2026-06-21T16:00:00Z', 'Mercedes-Benz Stadium', 'Atlanta'),

-- G | Belgica vs Iran | 3:00 PM ET = 19:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000025', '00000000-0000-0000-0000-000000000027',
 'G', 'group', '2026-06-21T19:00:00Z', 'SoFi Stadium', 'Inglewood'),

-- H | Uruguay vs Cabo Verde | 6:00 PM ET = 22:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000032', '00000000-0000-0000-0000-000000000030',
 'H', 'group', '2026-06-21T22:00:00Z', 'Hard Rock Stadium', 'Miami Gardens'),

-- G | Nueva Zelanda vs Egipto | 9:00 PM ET = 01:00 UTC (jun 22)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000028', '00000000-0000-0000-0000-000000000026',
 'G', 'group', '2026-06-22T01:00:00Z', 'BC Place', 'Vancouver'),

-- Lunes 22 jun
-- J | Argentina vs Austria | 1:00 PM ET = 17:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000037', '00000000-0000-0000-0000-000000000039',
 'J', 'group', '2026-06-22T17:00:00Z', 'AT&T Stadium', 'Arlington'),

-- I | Francia vs Irak | 5:00 PM ET = 21:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000033', '00000000-0000-0000-0000-000000000036',
 'I', 'group', '2026-06-22T21:00:00Z', 'Lincoln Financial Field', 'Filadelfia'),

-- I | Noruega vs Senegal | 8:00 PM ET = 00:00 UTC (jun 23)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000035', '00000000-0000-0000-0000-000000000034',
 'I', 'group', '2026-06-23T00:00:00Z', 'MetLife Stadium', 'East Rutherford'),

-- J | Jordania vs Argelia | 11:00 PM ET = 03:00 UTC (jun 23)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000040', '00000000-0000-0000-0000-000000000038',
 'J', 'group', '2026-06-23T03:00:00Z', 'Levis Stadium', 'Santa Clara'),

-- Martes 23 jun
-- K | Portugal vs Uzbekistan | 1:00 PM ET = 17:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000041', '00000000-0000-0000-0000-000000000043',
 'K', 'group', '2026-06-23T17:00:00Z', 'NRG Stadium', 'Houston'),

-- L | Inglaterra vs Ghana | 4:00 PM ET = 20:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000045', '00000000-0000-0000-0000-000000000047',
 'L', 'group', '2026-06-23T20:00:00Z', 'Gillette Stadium', 'Foxborough'),

-- L | Panama vs Croacia | 7:00 PM ET = 23:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000048', '00000000-0000-0000-0000-000000000046',
 'L', 'group', '2026-06-23T23:00:00Z', 'BMO Field', 'Toronto'),

-- K | Colombia vs Rep. Dem. del Congo | 10:00 PM ET = 02:00 UTC (jun 24)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000044', '00000000-0000-0000-0000-000000000042',
 'K', 'group', '2026-06-24T02:00:00Z', 'Estadio Akron', 'Zapopan'),


-- ===========================================================
-- JORNADA 3 — partidos simultaneos por grupo (fair play)
-- Cada par de partidos arranca exactamente al mismo tiempo.
-- ===========================================================

-- Miercoles 24 jun
-- B ── simultaneos a las 19:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000005',
 'B', 'group', '2026-06-24T19:00:00Z', 'BC Place', 'Vancouver'),
(gen_random_uuid(), '00000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000007',
 'B', 'group', '2026-06-24T19:00:00Z', 'Lumen Field', 'Seattle'),

-- C ── simultaneos a las 22:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000009',
 'C', 'group', '2026-06-24T22:00:00Z', 'Hard Rock Stadium', 'Miami Gardens'),
(gen_random_uuid(), '00000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000011',
 'C', 'group', '2026-06-24T22:00:00Z', 'Mercedes-Benz Stadium', 'Atlanta'),

-- A ── simultaneos a las 01:00 UTC (jun 25)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001',
 'A', 'group', '2026-06-25T01:00:00Z', 'Estadio Azteca', 'Ciudad de Mexico'),
(gen_random_uuid(), '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003',
 'A', 'group', '2026-06-25T01:00:00Z', 'Estadio BBVA', 'Monterrey'),

-- Jueves 25 jun
-- E ── simultaneos a las 20:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000018', '00000000-0000-0000-0000-000000000019',
 'E', 'group', '2026-06-25T20:00:00Z', 'Lincoln Financial Field', 'Filadelfia'),
(gen_random_uuid(), '00000000-0000-0000-0000-000000000020', '00000000-0000-0000-0000-000000000017',
 'E', 'group', '2026-06-25T20:00:00Z', 'MetLife Stadium', 'East Rutherford'),

-- F ── simultaneos a las 23:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000023',
 'F', 'group', '2026-06-25T23:00:00Z', 'AT&T Stadium', 'Arlington'),
(gen_random_uuid(), '00000000-0000-0000-0000-000000000024', '00000000-0000-0000-0000-000000000021',
 'F', 'group', '2026-06-25T23:00:00Z', 'Arrowhead Stadium', 'Kansas City'),

-- D ── simultaneos a las 02:00 UTC (jun 26)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000016', '00000000-0000-0000-0000-000000000013',
 'D', 'group', '2026-06-26T02:00:00Z', 'SoFi Stadium', 'Inglewood'),
(gen_random_uuid(), '00000000-0000-0000-0000-000000000014', '00000000-0000-0000-0000-000000000015',
 'D', 'group', '2026-06-26T02:00:00Z', 'Levis Stadium', 'Santa Clara'),

-- Viernes 26 jun
-- I ── simultaneos a las 19:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000035', '00000000-0000-0000-0000-000000000033',
 'I', 'group', '2026-06-26T19:00:00Z', 'Gillette Stadium', 'Foxborough'),
(gen_random_uuid(), '00000000-0000-0000-0000-000000000034', '00000000-0000-0000-0000-000000000036',
 'I', 'group', '2026-06-26T19:00:00Z', 'BMO Field', 'Toronto'),

-- H ── simultaneos a las 00:00 UTC (jun 27)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000030', '00000000-0000-0000-0000-000000000031',
 'H', 'group', '2026-06-27T00:00:00Z', 'NRG Stadium', 'Houston'),
(gen_random_uuid(), '00000000-0000-0000-0000-000000000032', '00000000-0000-0000-0000-000000000029',
 'H', 'group', '2026-06-27T00:00:00Z', 'Estadio Akron', 'Zapopan'),

-- G ── simultaneos a las 03:00 UTC (jun 27)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000026', '00000000-0000-0000-0000-000000000027',
 'G', 'group', '2026-06-27T03:00:00Z', 'Lumen Field', 'Seattle'),
(gen_random_uuid(), '00000000-0000-0000-0000-000000000028', '00000000-0000-0000-0000-000000000025',
 'G', 'group', '2026-06-27T03:00:00Z', 'BC Place', 'Vancouver'),

-- Sabado 27 jun
-- L ── simultaneos a las 21:00 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000048', '00000000-0000-0000-0000-000000000045',
 'L', 'group', '2026-06-27T21:00:00Z', 'MetLife Stadium', 'East Rutherford'),
(gen_random_uuid(), '00000000-0000-0000-0000-000000000046', '00000000-0000-0000-0000-000000000047',
 'L', 'group', '2026-06-27T21:00:00Z', 'Lincoln Financial Field', 'Filadelfia'),

-- K ── simultaneos a las 23:30 UTC
(gen_random_uuid(), '00000000-0000-0000-0000-000000000044', '00000000-0000-0000-0000-000000000041',
 'K', 'group', '2026-06-27T23:30:00Z', 'Hard Rock Stadium', 'Miami Gardens'),
(gen_random_uuid(), '00000000-0000-0000-0000-000000000042', '00000000-0000-0000-0000-000000000043',
 'K', 'group', '2026-06-27T23:30:00Z', 'Mercedes-Benz Stadium', 'Atlanta'),

-- J ── simultaneos a las 02:00 UTC (jun 28)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000038', '00000000-0000-0000-0000-000000000039',
 'J', 'group', '2026-06-28T02:00:00Z', 'Arrowhead Stadium', 'Kansas City'),
(gen_random_uuid(), '00000000-0000-0000-0000-000000000040', '00000000-0000-0000-0000-000000000037',
 'J', 'group', '2026-06-28T02:00:00Z', 'AT&T Stadium', 'Arlington');


-- Verificacion rapida (ejecutar a mano si queres confirmar):
-- SELECT COUNT(*) FROM teams;   --> 48
-- SELECT COUNT(*) FROM matches; --> 72
-- SELECT group_letter, COUNT(*) FROM matches GROUP BY group_letter ORDER BY group_letter;
-- --> cada letra debe tener 6

COMMIT;
