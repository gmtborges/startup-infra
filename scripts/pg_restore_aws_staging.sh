#!/bin/bash

export PGPASSWORD=passwd123
pg_restore -h db.staging.app.com -U app -d app --verbose --exit-on-error --no-password --no-owner --no-acl -Fc --schema=public --clean --if-exists aws-staging.dump

