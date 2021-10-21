class petl::mysql (
  $petl_mysql_user = decrypt(hiera("petl_mysql_user")),
  $petl_mysql_password = decrypt(hiera("petl_mysql_password"))
){

  mysql_user { "${petl_mysql_user}@localhost":
    ensure        => present,
    password_hash => mysql_password($petl_mysql_password),
    require => [ Service['mysqld']],
  } ->

  mysql_grant { "${petl_mysql_user}@localhost/*.*":
    options    => ['GRANT'],
    privileges => ['SELECT'],
    table => '*.*',
    user => "${petl_mysql_user}@localhost",
    require => [ Service['mysqld'] ],
  }

}