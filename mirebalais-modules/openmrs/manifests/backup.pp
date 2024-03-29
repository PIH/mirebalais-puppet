class openmrs::backup (
    $backup_user                      = decrypt(hiera('backup_db_user')),
    $backup_password                  = decrypt(hiera('backup_db_password')),
    $backup_time                      = hiera('backup_time'),
    $openmrs_percona_backup_enabled   = hiera('openmrs_percona_backup_enabled'),
    $openmrs_percona_install_mode     = hiera('openmrs_percona_install_mode'),
    $az_secret                        = decrypt(hiera('az_secret')),
    $az_url                           = decrypt(hiera('az_url')),
    $az_backup_folder_path            = hiera('az_backup_folder_path'),
    $azcopy_concurrency_value         = hiera('azcopy_concurrency_value'),
    $azcopy_concurrency_files         = hiera('azcopy_concurrency_files'),
    $remote_db_user                   = hiera('remote_db_user'),
    $remote_db_server                 = hiera('remote_db_server'),  # TODO is still used?
    $remote_backup_dir                = hiera('remote_backup_dir'),  # TODO is still used?
    $tomcat_home_dir                  = hiera('tomcat_home_dir'),
    $backup_file_prefix               = hiera('backup_file_prefix'),
    $backup_hour                      = hiera('backup_hour'),
    $backup_minute                    = hiera('backup_minute'),
    $backup_delete_older_than_x_days  = hiera('backup_delete_older_than_x_days'),
    $archive_hour                     = hiera('archive_hour'),
    $archive_minute                   = hiera('archive_minute'),
    $azure_backup_hour                = hiera('azure_backup_hour'),
    $azure_backup_minute              = hiera('azure_backup_minute'),
    $activitylog_enabled              = hiera('activitylog_enabled'),
    $terms_and_conditions_enabled     = hiera('terms_and_conditions_enabled'),
    $az_activitylog_backup_folder_path  = hiera('az_activitylog_backup_folder_path'),
    $sysadmin_email                   = hiera('sysadmin_email')
  ){

  require openmrs
  include azcopy

  database_user { "${backup_user}@localhost":
    ensure        => present,
    password_hash => mysql_password($backup_password),
    provider      => 'mysql',
    require       => Service['mysqld'],
  }

  database_grant { "${backup_user}@localhost":
    privileges => [ 'Select_priv', 'Reload_priv', 'Lock_tables_priv', 'Repl_client_priv', 'Repl_slave_priv', 'Show_view_priv', 'Process_priv' ],
    require    => Database_user["${backup_user}@localhost"],
  }

  cron { 'mysql-backup':
    ensure  => present,
    command => '/usr/local/sbin/mysqlbackup.sh',
    user    => 'root',
    hour    => "${backup_hour}",
    minute  => "${backup_minute}",
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

  file { 'backupAzure.sh':
    ensure  => present,
    path    => '/usr/local/sbin/backupAzure.sh',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('openmrs/backupAzure.sh.erb'),
    require => File["/usr/local/sbin/azcopy"]
  }

  cron { 'backup-az':
    ensure  => present,
    command => '/usr/bin/flock -n /home/tomcat/backups/cron.backupAzure.lock /usr/local/sbin/backupAzure.sh',
    user    => 'root',
    hour    => "${azure_backup_hour}",
    minute  => "${azure_backup_minute}",
    require => File['backupAzure.sh']
  }

  cron { 'mysql-archive':
    ensure  => present,
    command => '/usr/local/sbin/mysqlarchive.sh',
    user    => 'root',
    hour    => "${archive_hour}",
    minute  => "${archive_minute}",
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

  if $activitylog_enabled {
    file { 'backupActivityLog.sh':
      ensure  => present,
      path    => '/usr/local/sbin/backupActivityLog.sh',
      mode    => '0700',
      owner   => 'root',
      group   => 'root',
      content => template('openmrs/backupActivityLog.sh.erb'),
      require => File["/usr/local/sbin/azcopy"]
    }

    cron { 'backup-activitylog':
      ensure      => present,
      command     => '/usr/local/sbin/backupActivityLog.sh',
      user        => 'root',
      hour        => 19,
      minute      => 00,
      weekday     => 5,
      require     => File['backupActivityLog.sh']
    }
  }

}
