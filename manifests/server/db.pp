# Define for conveniently creating a role, database and assigning the correct
# permissions. See README.md for more details.
define postgresql::server::db (
  $user,
  $password,
  $dbname     = $title,
  $host       = $postgresql::server::host,
  $port       = $postgresql::server::port,
  $encoding   = $postgresql::server::encoding,
  $locale     = $postgresql::server::locale,
  $grant      = 'ALL',
  $tablespace = undef,
  $template   = 'template0',
  $istemplate = false,
  $owner      = undef
) {

  if ! defined(Postgresql::Server::Database[$title]) {
    postgresql::server::database { $title:
      dbname     => $dbname,
      encoding   => $encoding,
      tablespace => $tablespace,
      template   => $template,
      locale     => $locale,
      istemplate => $istemplate,
      owner      => $owner,
      host       => $host,
      port       => $port,
    }
  }

  if ! defined(Postgresql::Server::Role[$title]) {
    postgresql::server::role { $title:
      username      => $user,
      password_hash => $password,
      host          => $host,
      port          => $port,
    } -> Postgresql::Server::Database_grant<| role == $user |>
  }

  if ! defined(Postgresql::Server::Database_grant["GRANT ${user} - ${grant} - ${title} - ${host}"]) {
    postgresql::server::database_grant { "GRANT ${user} - ${grant} - ${title} - ${host}":
      privilege => $grant,
      db        => $dbname,
      host      => $host,
      port      => $port,
      role      => $user,
    } -> Postgresql::Validate_db_connection<| database_name == $dbname |>
  }

  if($tablespace != undef and defined(Postgresql::Server::Tablespace[$tablespace])) {
    Postgresql::Server::Tablespace[$tablespace]->Postgresql::Server::Database[$name]
  }
}
