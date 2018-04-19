alias psql-static-data="psqlConnectHeroku starfinder-static-data"
alias psql-pathfinder="psqlConnectHeroku pathfinder"

psqlConnectHeroku () {
  psql $(heroku config:get DATABASE_URL -a $1)
}
