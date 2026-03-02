import "dotenv/config";
import cors from "cors";
import express from "express";
import { neon } from "@neondatabase/serverless";

type Body = {
  fecha?: string;
  area: string;
  evaluacion_equipos: unknown;
};

const app = express();
const port = Number(process.env.PORT ?? 4000);
const corsOrigin = process.env.CORS_ORIGIN ?? "*";
const databaseUrl = process.env.DATABASE_URL;

if (!databaseUrl) {
  throw new Error("Falta la variable de entorno DATABASE_URL");
}

const sql = neon(databaseUrl);

app.use(cors({ origin: corsOrigin }));
app.use(express.json({ limit: "1mb" }));

app.get("/health", (_req, res) => {
  res.status(200).json({ ok: true, service: "pre-operativa-backend" });
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

    const rows = await sql`
      INSERT INTO inspecciones_preoperativas (fecha, area, evaluacion_equipos)
      VALUES (${fecha}::date, ${body.area}, ${JSON.stringify(body.evaluacion_equipos)}::jsonb)
      RETURNING id, fecha, area, evaluacion_equipos, created_at
    `;

    return res.status(201).json({ ok: true, data: rows[0] });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: "Error interno al guardar la inspección" });
  }
});

app.listen(port, () => {
  console.log(`Backend corriendo en http://localhost:${port}`);
});
