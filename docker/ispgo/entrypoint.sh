#!/bin/sh
# Entrada de la imagen de IspGo CRM. La misma imagen corre como web o como
# worker según ISPGO_ROLE, igual que las imágenes de IspGo en Coolify.
set -e

rm -f /app/tmp/pids/server.pid
rm -rf /app/tmp/cache/*

$(docker/entrypoints/helpers/pg_database_url.rb)
until pg_isready -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USERNAME"; do
  echo "Esperando la base de datos..."
  sleep 2
done

case "${ISPGO_ROLE:-web}" in
  web)
    # crea la base la primera vez y corre las migraciones en cada versión nueva
    bundle exec rails db:chatwoot_prepare
    exec bundle exec rails s -b 0.0.0.0 -p "${PORT:-3000}"
    ;;
  worker)
    exec bundle exec sidekiq -C config/sidekiq.yml
    ;;
  *)
    exec "$@"
    ;;
esac
