import "dotenv/config";
import cors from "cors";
import express from "express";
import { neon } from "@neondatabase/serverless";

type Body = {
  fecha?: string;
  area: string;
  responsable?: string;
  evaluacion_equipos: unknown;
};

type DeleteBody = {
  ids: string[];
};

type InspeccionRow = {
  id: string;
  fecha: string | Date;
  area: string;
  evaluacion_equipos: unknown;
  created_at: string | Date;
};

type EvaluacionNormalizada = {
  responsable: string;
  evaluacion_equipos: unknown[];
};

const app = express();
const port = Number(process.env.PORT ?? 4000);
const corsOrigin = process.env.CORS_ORIGIN ?? "*";
const databaseUrl = process.env.DATABASE_URL;
const resultsPassword = process.env.RESULTS_PASSWORD ?? "PaolaLoca";

const normalizeOrigin = (value: string) => value.replace(/\/$/, "").trim();

const allowedOrigins = corsOrigin
  .split(",")
  .map((origin) => normalizeOrigin(origin))
  .filter(Boolean);

if (!databaseUrl) {
  throw new Error("Falta la variable de entorno DATABASE_URL");
}

const sql = neon(databaseUrl);

const normalizeEvaluacion = (value: unknown): EvaluacionNormalizada => {
  if (Array.isArray(value)) {
    return {
      responsable: "",
      evaluacion_equipos: value,
    };
  }

  if (value && typeof value === "object") {
    const asObject = value as { responsable?: unknown; equipos?: unknown };
    return {
      responsable: typeof asObject.responsable === "string" ? asObject.responsable : "",
      evaluacion_equipos: Array.isArray(asObject.equipos) ? asObject.equipos : [],
    };
  }

  return {
    responsable: "",
    evaluacion_equipos: [],
  };
};

app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin) {
        callback(null, true);
        return;
      }

      const normalizedRequestOrigin = normalizeOrigin(origin);

      if (allowedOrigins.includes("*")) {
        callback(null, true);
        return;
      }

      if (allowedOrigins.includes(normalizedRequestOrigin)) {
        callback(null, true);
        return;
      }

      callback(new Error("Origen no permitido por CORS"));
    },
  })
);
app.use(express.json({ limit: "1mb" }));

app.get("/health", (_req, res) => {
  res.status(200).json({ ok: true, service: "pre-operativa-backend" });
});

app.get("/api/inspecciones-preoperativas", async (req, res) => {
  try {
    const providedPassword = req.header("x-results-password");

    if (!providedPassword || providedPassword !== resultsPassword) {
      return res.status(401).json({ error: "No autorizado" });
    }

    const area = typeof req.query.area === "string" ? req.query.area.trim() : "";
    const from = typeof req.query.from === "string" ? req.query.from : "";
    const to = typeof req.query.to === "string" ? req.query.to : "";

    const rows = (await sql`
      SELECT id, fecha, area, evaluacion_equipos, created_at
      FROM inspecciones_preoperativas
      WHERE (${area} = '' OR area = ${area})
        AND (${from} = '' OR fecha >= ${from}::date)
        AND (${to} = '' OR fecha <= ${to}::date)
      ORDER BY fecha DESC, created_at DESC
      LIMIT 2000
    `) as InspeccionRow[];

    const normalizedRows = rows.map((row) => {
      const parsed = normalizeEvaluacion(row.evaluacion_equipos);
      return {
        ...row,
        responsable: parsed.responsable,
        evaluacion_equipos: parsed.evaluacion_equipos,
        fecha:
          typeof row.fecha === "string"
            ? row.fecha.slice(0, 10)
            : row.fecha.toISOString().slice(0, 10),
        created_at:
          typeof row.created_at === "string" ? row.created_at : row.created_at.toISOString(),
      };
    });

    return res.status(200).json({ ok: true, count: normalizedRows.length, data: normalizedRows });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: "Error interno al consultar inspecciones" });
  }
});

app.post("/api/inspecciones-preoperativas", async (req, res) => {
  try {
    const body = req.body as Body;

    if (!body?.area || !body?.evaluacion_equipos) {
      return res
        .status(400)
        .json({ error: "area y evaluacion_equipos son obligatorios" });
    }

    const fecha = body.fecha ?? new Date().toISOString().slice(0, 10);
    const evaluacionJson = {
      responsable: typeof body.responsable === "string" ? body.responsable.trim() : "",
      equipos: body.evaluacion_equipos,
    };

    const rows = await sql`
      INSERT INTO inspecciones_preoperativas (fecha, area, evaluacion_equipos)
      VALUES (${fecha}::date, ${body.area}, ${JSON.stringify(evaluacionJson)}::jsonb)
      RETURNING id, fecha, area, evaluacion_equipos, created_at
    `;

    return res.status(201).json({ ok: true, data: rows[0] });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: "Error interno al guardar la inspección" });
  }
});

app.delete("/api/inspecciones-preoperativas", async (req, res) => {
  try {
    const providedPassword = req.header("x-results-password");

    if (!providedPassword || providedPassword !== resultsPassword) {
      return res.status(401).json({ error: "No autorizado" });
    }

    const body = req.body as DeleteBody;
    const ids = Array.isArray(body?.ids)
      ? body.ids.filter((id) => typeof id === "string" && id.trim() !== "")
      : [];

    if (ids.length === 0) {
      return res.status(400).json({ error: "Debes enviar al menos un id para eliminar" });
    }

    if (ids.length > 200) {
      return res.status(400).json({ error: "Máximo 200 registros por eliminación" });
    }

    const idsJson = JSON.stringify(ids);

    const rows = await sql`
      DELETE FROM inspecciones_preoperativas
      WHERE id IN (
        SELECT jsonb_array_elements_text(${idsJson}::jsonb)::uuid
      )
      RETURNING id
    `;

    return res.status(200).json({ ok: true, deletedCount: rows.length });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: "Error interno al eliminar inspecciones" });
  }
});

app.listen(port, () => {
  console.log(`Backend corriendo en http://localhost:${port}`);
});
