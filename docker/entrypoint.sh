#!/usr/bin/env bash
set -euo pipefail

cd /app

if [[ -n "${DATABASE_HOST:-}" ]]; then
  export PGPASSWORD="${DATABASE_PASSWORD:-}"
  echo "Waiting for PostgreSQL at ${DATABASE_HOST}:${DATABASE_PORT:-5432}..."
  export DB_HOST="$DATABASE_HOST"
  export DB_PORT="${DATABASE_PORT:-5432}"
  while ! ruby -rsocket -e 'begin; Socket.tcp(ENV["DB_HOST"], Integer(ENV["DB_PORT"]), connect_timeout: 2) { |s| s.close }; rescue; exit 1; end' >/dev/null 2>&1; do
    sleep 1
  done
fi

bundle check || bundle install

if [[ "${RUN_DB_SETUP:-true}" == "true" ]]; then
  ADMIN_USER="${DATABASE_ADMIN_USERNAME:-postgres}"
  ADMIN_PASSWORD="${DATABASE_ADMIN_PASSWORD:-postgres}"
  APP_USER="${DATABASE_USERNAME:-nlcommons}"
  APP_PASSWORD="${DATABASE_PASSWORD:-nlcommons}"
  APP_DB="${DATABASE_NAME:-nlcommons_development}"

  export PGPASSWORD="$ADMIN_PASSWORD"

  psql -h "${DATABASE_HOST:-db}" -p "${DATABASE_PORT:-5432}" -U "$ADMIN_USER" -d postgres \
    -tc "SELECT 1 FROM pg_roles WHERE rolname='${APP_USER}'" | grep -q 1 \
    || psql -h "${DATABASE_HOST:-db}" -p "${DATABASE_PORT:-5432}" -U "$ADMIN_USER" -d postgres \
      -c "CREATE ROLE ${APP_USER} LOGIN PASSWORD '${APP_PASSWORD}';"

  psql -h "${DATABASE_HOST:-db}" -p "${DATABASE_PORT:-5432}" -U "$ADMIN_USER" -d postgres \
    -tc "SELECT 1 FROM pg_database WHERE datname='${APP_DB}'" | grep -q 1 \
    || psql -h "${DATABASE_HOST:-db}" -p "${DATABASE_PORT:-5432}" -U "$ADMIN_USER" -d postgres \
      -c "CREATE DATABASE ${APP_DB} OWNER ${APP_USER};"

  if ! psql -h "${DATABASE_HOST:-db}" -p "${DATABASE_PORT:-5432}" -U "$ADMIN_USER" \
      -d "$APP_DB" -tAc "SELECT 1 FROM information_schema.tables WHERE table_name='nodes'" | grep -q 1; then
    psql -h "${DATABASE_HOST:-db}" -p "${DATABASE_PORT:-5432}" -U "$ADMIN_USER" \
      -d "$APP_DB" -f /app/db/schema.sql
    psql -h "${DATABASE_HOST:-db}" -p "${DATABASE_PORT:-5432}" -U "$ADMIN_USER" \
      -d "$APP_DB" -f /app/db/base_data.sql
    psql -h "${DATABASE_HOST:-db}" -p "${DATABASE_PORT:-5432}" -U "$ADMIN_USER" \
      -d "$APP_DB" -c "GRANT ALL PRIVILEGES ON DATABASE ${APP_DB} TO ${APP_USER};"
    psql -h "${DATABASE_HOST:-db}" -p "${DATABASE_PORT:-5432}" -U "$ADMIN_USER" \
      -d "$APP_DB" -c "GRANT ALL ON ALL TABLES IN SCHEMA public TO ${APP_USER};"
    psql -h "${DATABASE_HOST:-db}" -p "${DATABASE_PORT:-5432}" -U "$ADMIN_USER" \
      -d "$APP_DB" -c "GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO ${APP_USER};"
    psql -h "${DATABASE_HOST:-db}" -p "${DATABASE_PORT:-5432}" -U "$ADMIN_USER" \
      -d "$APP_DB" -c "GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO ${APP_USER};"
    psql -h "${DATABASE_HOST:-db}" -p "${DATABASE_PORT:-5432}" -U "$ADMIN_USER" \
      -d "$APP_DB" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${APP_USER};"
    psql -h "${DATABASE_HOST:-db}" -p "${DATABASE_PORT:-5432}" -U "$ADMIN_USER" \
      -d "$APP_DB" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${APP_USER};"
    psql -h "${DATABASE_HOST:-db}" -p "${DATABASE_PORT:-5432}" -U "$ADMIN_USER" \
      -d "$APP_DB" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO ${APP_USER};"
  fi
fi

exec "$@"
