CREATE TABLE IF NOT EXISTS UserProfiles (
  Id                        SERIAL PRIMARY KEY,
  UserId                    TEXT NOT NULL UNIQUE,
  UserName                  TEXT,
  RegistrationDate          TEXT,
  OnboardingDate            TEXT,
  DeviceModel               TEXT,
  OsVersion                 TEXT,
  Platform                  TEXT,
  AppVersion                TEXT,
  ThemeMode                 TEXT,
  TextScale                 DOUBLE PRECISION,
  ScriptMode                TEXT,
  AppLanguage               TEXT,
  NotificationEnabled       BOOLEAN,
  NotificationTime          TEXT,
  AutoPlayEnabled           BOOLEAN,
  RepeatCurrentEnabled      BOOLEAN,
  CrossfadeDurationSeconds  INTEGER,
  OnboardingCompleted       BOOLEAN,
  ProfileComplete           BOOLEAN,
  LastUpdated               TIMESTAMPTZ,
  FirstSeen                 TIMESTAMPTZ DEFAULT NOW()
);

-- Upsert query (use in n8n Postgres node):
INSERT INTO UserProfiles (
  UserId, UserName, RegistrationDate, OnboardingDate, DeviceModel, OsVersion,
  Platform, AppVersion, ThemeMode, TextScale, ScriptMode, AppLanguage,
  NotificationEnabled, NotificationTime, AutoPlayEnabled, RepeatCurrentEnabled,
  CrossfadeDurationSeconds, OnboardingCompleted, ProfileComplete, LastUpdated
) VALUES (
  $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20
)
ON CONFLICT (UserId) DO UPDATE SET
  UserName                   = EXCLUDED.UserName,
  RegistrationDate           = EXCLUDED.RegistrationDate,
  OnboardingDate             = EXCLUDED.OnboardingDate,
  DeviceModel                = EXCLUDED.DeviceModel,
  OsVersion                  = EXCLUDED.OsVersion,
  Platform                   = EXCLUDED.Platform,
  AppVersion                 = EXCLUDED.AppVersion,
  ThemeMode                  = EXCLUDED.ThemeMode,
  TextScale                  = EXCLUDED.TextScale,
  ScriptMode                 = EXCLUDED.ScriptMode,
  AppLanguage                = EXCLUDED.AppLanguage,
  NotificationEnabled        = EXCLUDED.NotificationEnabled,
  NotificationTime           = EXCLUDED.NotificationTime,
  AutoPlayEnabled            = EXCLUDED.AutoPlayEnabled,
  RepeatCurrentEnabled       = EXCLUDED.RepeatCurrentEnabled,
  CrossfadeDurationSeconds   = EXCLUDED.CrossfadeDurationSeconds,
  OnboardingCompleted        = EXCLUDED.OnboardingCompleted,
  ProfileComplete            = EXCLUDED.ProfileComplete,
  LastUpdated                = EXCLUDED.LastUpdated;