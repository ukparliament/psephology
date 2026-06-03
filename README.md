# README

## Reminder on how to pull/push db

heroku pg:pull DATABASE_URL localdbname --remote heroku
heroku pg:reset --remote test
heroku pg:push localdbname DATABASE_URL --remote test
