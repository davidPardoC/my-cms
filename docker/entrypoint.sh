#!/bin/sh
set -eu

APP_UID=1000
APP_GID=1000
UPLOADS_DIR="/opt/app/public/uploads"

echo "[Entrypoint] Verificando permisos de ${UPLOADS_DIR}..."

# Si el directorio existe, corregir permisos
if [ -d "$UPLOADS_DIR" ]; then
  chown -R ${APP_UID}:${APP_GID} "$UPLOADS_DIR" || echo "[Entrypoint] Aviso: no se pudieron cambiar los permisos (quizás sea un volumen de solo lectura)"
  chmod -R 755 "$UPLOADS_DIR" || true
else
  echo "[Entrypoint] Carpeta uploads no encontrada, creando..."
  mkdir -p "$UPLOADS_DIR"
  chown -R ${APP_UID}:${APP_GID} "$UPLOADS_DIR"
  chmod -R 755 "$UPLOADS_DIR"
fi

echo "[Entrypoint] Permisos aplicados, ejecutando Strapi como usuario 'node'..."

# Ejecutar Strapi con privilegios reducidos
exec su-exec ${APP_UID}:${APP_GID} "$@"
