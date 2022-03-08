class petl::mysql (
  $petl_mysql_user = decrypt(hiera("petl_mysql_user")),
  $petl_mysql_password = decrypt(hiera("petl_mysql_password")),
  $install_petl_warehouse_db = hiera("install_petl_warehouse_db"),
  $petl_warehouse_db = hiera("petl_warehouse_db"),
  $petl_mysql_user_ip = hiera("petl_mysql_user_ip"),
  $openmrs_db = hiera('openmrs_db'),
){

  if $install_petl_warehouse_db {
    mysql_database { "$petl_warehouse_db":
      ensure  => present,
      require => [Service['mysqld']],
      charset => 'utf8',
    } ->

    mysql_grant { "${petl_mysql_user}@${petl_mysql_user_ip}/${petl_warehouse_db}.*":
      options    => ['GRANT'],
      privileges => ['ALL'],
      table => '*.*',
      user => "${petl_mysql_user}@${petl_mysql_user_ip}",
      require => [Service['mysqld']],
    }
  }

  mysql_user { "${petl_mysql_user}@${petl_mysql_user_ip}":
    ensure        => present,
    password_hash => mysql_password($petl_mysql_password),
    require => [Service['mysqld']],
  } ->

  mysql_grant { "${petl_mysql_user}@${petl_mysql_user_ip}/${openmrs_db}.*":
    options    => ['GRANT'],
    privileges => ['ALL'],
    table => '*.*',
    user => "${petl_mysql_user}@${petl_mysql_user_ip}",
    require => [Service['mysqld']],
  }

}