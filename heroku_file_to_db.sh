pg_restore --verbose --clean --no-acl --no-owner -h localhost -d psephology latest.dump
rake db:migrate

