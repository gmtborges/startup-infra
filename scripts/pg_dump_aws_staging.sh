#!/bin/bash
pg_dump --no-acl \
  --no-owner -Fc \
  --verbose \
  --schema=public \
  postgres://app:passwd123@db.staging.app.com > aws-staging.dump

