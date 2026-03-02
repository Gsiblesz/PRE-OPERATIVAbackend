CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS inspecciones_preoperativas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fecha DATE NOT NULL,
  area VARCHAR(100) NOT NULL,
  evaluacion_equipos JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_inspecciones_fecha
  ON inspecciones_preoperativas (fecha);

CREATE INDEX IF NOT EXISTS idx_inspecciones_area
  ON inspecciones_preoperativas (area);

CREATE INDEX IF NOT EXISTS idx_inspecciones_eval_jsonb
  ON inspecciones_preoperativas USING GIN (evaluacion_equipos);
