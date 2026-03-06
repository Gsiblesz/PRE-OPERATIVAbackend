-- Datos de prueba para visualizar gráficas con volumen y fechas variadas.
-- Genera registros diarios del 2026-01-01 al 2026-04-30.

DELETE FROM inspecciones_preoperativas
WHERE fecha BETWEEN DATE '2026-01-01' AND DATE '2026-04-30'
  AND area IN ('Panadería', 'Hojaldre', 'Área de donas');

WITH base AS (
  SELECT
    d::date AS fecha,
    ROW_NUMBER() OVER (ORDER BY d)::int AS idx,
    CASE (EXTRACT(DOY FROM d)::int % 3)
      WHEN 0 THEN 'Panadería'
      WHEN 1 THEN 'Hojaldre'
      ELSE 'Área de donas'
    END AS area
  FROM generate_series(DATE '2026-01-01', DATE '2026-04-30', INTERVAL '1 day') AS serie(d)
)
INSERT INTO inspecciones_preoperativas (fecha, area, evaluacion_equipos)
SELECT
  b.fecha,
  b.area,
  jsonb_build_object(
    'responsable',
    (ARRAY['Gerardo Siblesz', 'Paola Méndez', 'Carlos Medina', 'Andrea Pérez', 'Luis Gómez', 'María Suárez'])[(b.idx % 6) + 1],
    'equipos',
    CASE b.area
      WHEN 'Panadería' THEN jsonb_build_array(
        jsonb_build_object(
          'equipoId', 'mezcladora-1',
          'equipoNombre', 'Mezcladora #1',
          'aspectos', jsonb_build_array(
            jsonb_build_object('aspecto', 'Rejilla de seguridad', 'estado', CASE WHEN b.idx % 12 IN (0, 3) THEN 'no_conforme' ELSE 'conforme' END),
            jsonb_build_object('aspecto', 'Tolva', 'estado', CASE WHEN b.idx % 10 = 0 THEN 'no_conforme' ELSE 'conforme' END),
            jsonb_build_object('aspecto', 'Superficie externa', 'estado', CASE WHEN b.idx % 15 = 0 THEN 'no_conforme' ELSE 'conforme' END)
          ),
          'observacionEquipo', CASE WHEN b.idx % 6 = 0 THEN 'Residuo de harina en tolva al inicio del turno' ELSE '' END
        ),
        jsonb_build_object(
          'equipoId', 'formadora-masa-1',
          'equipoNombre', 'Formadora de masa #1',
          'aspectos', jsonb_build_array(
            jsonb_build_object('aspecto', 'Lona transportadora', 'estado', CASE WHEN b.idx % 9 IN (0, 2) THEN 'no_conforme' ELSE 'conforme' END),
            jsonb_build_object('aspecto', 'Superficie interna', 'estado', CASE WHEN b.idx % 13 = 0 THEN 'no_conforme' ELSE 'conforme' END),
            jsonb_build_object('aspecto', 'Pisos', 'estado', CASE WHEN b.idx % 8 = 0 THEN 'no_conforme' ELSE 'conforme' END)
          ),
          'observacionEquipo', CASE WHEN b.idx % 8 = 0 THEN 'Limpieza parcial en banda transportadora' ELSE '' END
        ),
        jsonb_build_object(
          'equipoId', 'horno-imperial',
          'equipoNombre', 'Horno imperial',
          'aspectos', jsonb_build_array(
            jsonb_build_object('aspecto', 'Superficie interna', 'estado', CASE WHEN b.idx % 14 = 0 THEN 'no_conforme' ELSE 'conforme' END),
            jsonb_build_object('aspecto', 'Base del equipo', 'estado', CASE WHEN b.idx % 11 = 0 THEN 'no_conforme' ELSE 'conforme' END),
            jsonb_build_object('aspecto', 'Presencia de materiales extraños', 'estado', CASE WHEN b.idx % 16 = 0 THEN 'no_conforme' ELSE 'conforme' END)
          ),
          'observacionEquipo', CASE WHEN b.idx % 14 = 0 THEN 'Requiere limpieza profunda de base y laterales' ELSE '' END
        )
      )
      WHEN 'Hojaldre' THEN jsonb_build_array(
        jsonb_build_object(
          'equipoId', 'mezcladora-9',
          'equipoNombre', 'Mezcladora #9',
          'aspectos', jsonb_build_array(
            jsonb_build_object('aspecto', 'Rejilla de seguridad', 'estado', CASE WHEN b.idx % 11 IN (0, 4) THEN 'no_conforme' ELSE 'conforme' END),
            jsonb_build_object('aspecto', 'Gancho', 'estado', CASE WHEN b.idx % 10 = 0 THEN 'no_conforme' ELSE 'conforme' END),
            jsonb_build_object('aspecto', 'Superficie externa', 'estado', CASE WHEN b.idx % 12 = 0 THEN 'no_conforme' ELSE 'conforme' END)
          ),
          'observacionEquipo', CASE WHEN b.idx % 10 = 0 THEN 'Trazas de masa seca en gancho y perímetro' ELSE '' END
        ),
        jsonb_build_object(
          'equipoId', 'laminadora-1',
          'equipoNombre', 'Laminadora #1',
          'aspectos', jsonb_build_array(
            jsonb_build_object('aspecto', 'Lona transportadora', 'estado', CASE WHEN b.idx % 9 IN (0, 5) THEN 'no_conforme' ELSE 'conforme' END),
            jsonb_build_object('aspecto', 'Mesón de la laminadora', 'estado', CASE WHEN b.idx % 13 = 0 THEN 'no_conforme' ELSE 'conforme' END),
            jsonb_build_object('aspecto', 'Pisos', 'estado', CASE WHEN b.idx % 7 = 0 THEN 'no_conforme' ELSE 'conforme' END)
          ),
          'observacionEquipo', CASE WHEN b.idx % 7 = 0 THEN 'Acumulación de harina en piso cercano a la lona' ELSE '' END
        ),
        jsonb_build_object(
          'equipoId', 'abatidor',
          'equipoNombre', 'Abatidor',
          'aspectos', jsonb_build_array(
            jsonb_build_object('aspecto', 'Manillas y puertas', 'estado', CASE WHEN b.idx % 8 = 0 THEN 'no_conforme' ELSE 'conforme' END),
            jsonb_build_object('aspecto', 'Rieles internos', 'estado', CASE WHEN b.idx % 12 IN (0, 1) THEN 'no_conforme' ELSE 'conforme' END),
            jsonb_build_object('aspecto', 'Paredes internas', 'estado', CASE WHEN b.idx % 14 = 0 THEN 'no_conforme' ELSE 'conforme' END)
          ),
          'observacionEquipo', CASE WHEN b.idx % 12 = 0 THEN 'Rieles internos con limpieza incompleta' ELSE '' END
        )
      )
      ELSE jsonb_build_array(
        jsonb_build_object(
          'equipoId', 'freidora',
          'equipoNombre', 'Freidora',
          'aspectos', jsonb_build_array(
            jsonb_build_object('aspecto', 'Superficie externa', 'estado', CASE WHEN b.idx % 9 IN (0, 3) THEN 'no_conforme' ELSE 'conforme' END),
            jsonb_build_object('aspecto', 'Pisos', 'estado', CASE WHEN b.idx % 8 = 0 THEN 'no_conforme' ELSE 'conforme' END),
            jsonb_build_object('aspecto', 'Campana', 'estado', CASE WHEN b.idx % 11 = 0 THEN 'no_conforme' ELSE 'conforme' END)
          ),
          'observacionEquipo', CASE WHEN b.idx % 9 = 0 THEN 'Salpicaduras de aceite en campana y piso' ELSE '' END
        ),
        jsonb_build_object(
          'equipoId', 'batidora-2',
          'equipoNombre', 'Batidora #2',
          'aspectos', jsonb_build_array(
            jsonb_build_object('aspecto', 'Tolva', 'estado', CASE WHEN b.idx % 10 = 0 THEN 'no_conforme' ELSE 'conforme' END),
            jsonb_build_object('aspecto', 'Gancho', 'estado', CASE WHEN b.idx % 12 = 0 THEN 'no_conforme' ELSE 'conforme' END),
            jsonb_build_object('aspecto', 'Presencia de materiales extraños', 'estado', CASE WHEN b.idx % 14 = 0 THEN 'no_conforme' ELSE 'conforme' END)
          ),
          'observacionEquipo', CASE WHEN b.idx % 10 = 0 THEN 'Material particulado detectado en borde de tolva' ELSE '' END
        ),
        jsonb_build_object(
          'equipoId', 'mesones-donas',
          'equipoNombre', 'Mesones donas',
          'aspectos', jsonb_build_array(
            jsonb_build_object('aspecto', 'Superficie superior', 'estado', CASE WHEN b.idx % 7 = 0 THEN 'no_conforme' ELSE 'conforme' END),
            jsonb_build_object('aspecto', 'Estructura inferior (patas y estantes)', 'estado', CASE WHEN b.idx % 13 = 0 THEN 'no_conforme' ELSE 'conforme' END),
            jsonb_build_object('aspecto', 'Buenas prácticas de almacenamiento', 'estado', CASE WHEN b.idx % 11 IN (0, 2) THEN 'no_conforme' ELSE 'conforme' END)
          ),
          'observacionEquipo', CASE WHEN b.idx % 11 = 0 THEN 'Utensilios fuera de ubicación estándar en mesón' ELSE '' END
        )
      )
    END
  ) AS evaluacion_equipos;

-- Verificación rápida
-- SELECT area, COUNT(*) AS registros, MIN(fecha) AS desde, MAX(fecha) AS hasta
-- FROM inspecciones_preoperativas
-- WHERE fecha BETWEEN DATE '2026-01-01' AND DATE '2026-04-30'
-- GROUP BY area
-- ORDER BY area;