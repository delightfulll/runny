-- Runny database schema (derived from backend/src/routes/* queries and the iOS models).
-- Safe to run multiple times.

CREATE TABLE IF NOT EXISTS users (
  id               TEXT PRIMARY KEY,
  name             TEXT NOT NULL,
  email            TEXT NOT NULL UNIQUE,
  password_hash    TEXT NOT NULL,
  yesterday_strain DOUBLE PRECISION NOT NULL DEFAULT 0,
  daily_streak     INTEGER NOT NULL DEFAULT 0,
  recovery         DOUBLE PRECISION NOT NULL DEFAULT 100,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS activities (
  id           TEXT PRIMARY KEY,
  user_id      TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type         TEXT NOT NULL CHECK (type IN ('running', 'biking', 'weightlifting', 'walking')),
  distance     DOUBLE PRECISION,
  time         DOUBLE PRECISION NOT NULL,
  date         TIMESTAMPTZ NOT NULL,
  calories     INTEGER NOT NULL DEFAULT 0,
  difficulty   TEXT NOT NULL CHECK (difficulty IN ('easy', 'mid', 'hard')),
  average_pace DOUBLE PRECISION NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS activities_user_date_idx ON activities (user_id, date DESC);
