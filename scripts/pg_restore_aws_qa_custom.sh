#!/bin/bash

export PGPASSWORD=passwd123
pg_restore -h db.qa.app.com \
  -U app \
  -d $1 \
  --verbose \
  --exit-on-error \
  --no-password \
  --no-owner \
  --no-acl -Fc \
  --schema=public \
  --clean aws-stg.dump

