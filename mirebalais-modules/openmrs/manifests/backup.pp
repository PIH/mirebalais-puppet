class openmrs::backup (
    $backup_user = decrypt(hiera('backup_db_user')),
    $backup_password = decrypt(hiera('backup_db_password')),
    $remote_db_user = hiera('remote_db_user'),
    $remote_db_server = hiera('remote_db_server'),
    $remote_backup_dir = hiera('remote_backup_dir'),
    $tomcat = hiera('tomcat'),
    $sysadmin_email = hiera('sysadmin_email'),
    $backup_file_prefix = hiera('backup_file_prefix'),
    $backup_hour = hiera('backup_hour'),
    $backup_delete_older_than_x_days = hiera('backup_delete_older_than_x_days'),
    $archive_hour = hiera('archive_hour'),
  ){

  database_user { "${backup_user}@localhost":
    ensure        => present,
    password_hash => mysql_password($backup_password),
    provider      => 'mysql',
    require       => Service['mysqld'],
  }

  database_grant { "${backup_user}@localhost":
    privileges => [ 'Select_priv', 'Reload_priv', 'Lock_tables_priv', 'Repl_client_priv', 'Repl_slave_priv', 'Show_view_priv' ],
    require    => Database_user["${backup_user}@localhost"],
  }

  cron { 'mysql-backup':
    ensure  => present,
    command => '/usr/local/sbin/mysqlbackup.sh > /dev/null',
    user    => 'root',
    hour    => "${backup_hour}",
    minute  => 30,
    environment => "MAILTO=${sysadmin_email}",
    require => [ File['mysqlbackup.sh'], Package['p7zip-full'] ]
  }

  file { 'mysqlbackup.sh':
    ensure  => present,
    path    => '/usr/local/sbin/mysqlbackup.sh',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('openmrs/mysqlbackup.sh.erb'),
  }

  cron { 'mysql-archive':
    ensure  => present,
    command => '/usr/local/sbin/mysqlarchive.sh > /dev/null',
    user     => 'root',
    minute => 30,
    hour => "${archive_hour}",
    environment => "MAILTO=${sysadmin_email}",
    require => [ File['mysqlarchive.sh'] ]
  }

  file { 'mysqlarchive.sh':
    ensure  => present,
    path    => '/usr/local/sbin/mysqlarchive.sh',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('openmrs/mysqlarchive.sh.erb'),
  }
}
