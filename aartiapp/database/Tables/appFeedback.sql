CREATE TABLE IF NOT EXISTS appFeedback (
  Id                 SERIAL PRIMARY KEY,
  FeedbackId         UUID NOT NULL UNIQUE,
  UserId             TEXT,
  UserName           TEXT,
  Email              TEXT,
  RegistrationDate   TEXT,
  OnboardingDate     TEXT,
  DeviceModel        TEXT,
  OsVersion          TEXT,
  Platform           TEXT,
  AppVersion         TEXT,
  FeedbackType       TEXT,
  Message            TEXT,
  SubmittedAt        TIMESTAMPTZ,
  ReceivedAtServer   TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_feedback_user_id
  ON appFeedback (UserId);

CREATE INDEX IF NOT EXISTS idx_app_feedback_submitted_at
  ON appFeedback (SubmittedAt DESC);

-- Insert query (use in n8n Postgres node):
INSERT INTO appFeedback (
  FeedbackId, UserId, UserName, Email, RegistrationDate, OnboardingDate, DeviceModel,
  OsVersion, Platform, AppVersion, FeedbackType, Message, SubmittedAt, ReceivedAtServer
) VALUES (
  $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14
);