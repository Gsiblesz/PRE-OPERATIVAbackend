# Backend - PRE OPERATIVA

API para guardar inspecciones preoperativas en Neon (PostgreSQL), preparada para Render.

## Estructura

```text
backend/
├── src/server.ts
├── database/inspecciones_preoperativas.sql
├── .env.example
├── .gitignore
├── package.json
└── tsconfig.json
```

## Ejecutar local

1. Instala dependencias:

   ```bash
   npm install
   ```

2. Crea `.env` desde `.env.example`.

3. Ejecuta:

   ```bash
   npm run dev
   ```

## Endpoints

- `GET /health`
- `POST /api/inspecciones-preoperativas`
- `GET /api/inspecciones-preoperativas` (protegido con header `x-results-password`)

## Deploy en Render

- Build Command: `npm install ; npm run build`
- Start Command: `npm run start`
- Variables:
  - `DATABASE_URL`
  - `PORT` (Render la inyecta automáticamente, opcional en panel)
  - `CORS_ORIGIN=https://tu-frontend.vercel.app`
   - `RESULTS_PASSWORD=PaolaLoca`

## Base de datos Neon

Ejecuta el script `database/inspecciones_preoperativas.sql` en el SQL Editor de Neon.
