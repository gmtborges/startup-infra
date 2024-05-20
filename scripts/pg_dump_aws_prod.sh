#!/bin/bash
rm -rf db-dump;
mkdir db-dump;
pg_dump --no-acl \
  --no-owner \
  --verbose \
  --schema=public \
  -j 8 \
  -h db.example.com \
  -U user \
  dbname \
  -Fd -f db-dump

