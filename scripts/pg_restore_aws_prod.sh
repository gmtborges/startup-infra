#!/bin/bash
pg_restore -h db.prod.app.gg -U user -d dbname \
  --verbose \
  --exit-on-error \
  --no-password \
  --no-owner \
  --no-acl \
  --schema=public \
  --clean \
  --if-exists \
  -j 10 \
  -Fd db-dump
