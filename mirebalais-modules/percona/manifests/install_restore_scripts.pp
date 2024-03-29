class percona::install_restore_scripts (
    $percona_home_dir                  = hiera('percona_home_dir'),
    $percona_restore_dir               = hiera('percona_restore_dir'),
    $backup_password                   = decrypt(hiera('backup_db_password')),
    $percona_mysql_root_password       = decrypt(hiera('percona_mysql_root_password')),
    $az_url                            = decrypt(hiera('az_url')),
    $az_secret                         = decrypt(hiera('az_secret')),
    $percona_backup_ssh_host           = decrypt(hiera('percona_backup_ssh_host')),
    $percona_backup_ssh_user           = decrypt(hiera('percona_backup_ssh_user')),
    $percona_backup_dir                = decrypt(hiera('percona_backup_dir')),
    $tomcat_home_dir                   = decrypt(hiera('tomcat_home_dir')),
    $sysadmin_email                    = decrypt(hiera('sysadmin_email')),
    $petl_mysql_user                   = decrypt(hiera('petl_mysql_user')),
    $petl_mysql_password               = decrypt(hiera('petl_mysql_password')),
    $openmrs_db                        = decrypt(hiera('openmrs_db')),
  ) {

    include azcopy

    file { '/root/.percona.env':
      ensure  => present,
      path    => '/root/.percona.env',
      mode    => '0700',
      owner   => 'root',
      group   => 'root',
      content => template('percona/percona.env.erb'),
    }
    file { "${percona_home_dir}":
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => '0755',
      require     => File["/root/.percona.env"]
    }
    file { "${percona_restore_dir}":
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => '0755',
      require     => File["${percona_home_dir}"]
    }
    file { '${percona_restore_dir}/deidentify-db.sql':
      ensure => present,
      source => 'puppet:///modules/percona/deidentify-db.sql',
      path    => "${percona_restore_dir}/deidentify-db.sql",
      mode    => '0700',
      owner   => 'root',
      group   => 'root',
      require => File["${percona_restore_dir}"]
    }
    file { '${percona_restore_dir}/percona-restore.sh':
      ensure => present,
      source => 'puppet:///modules/percona/percona-restore.sh',
      path    => "${percona_restore_dir}/percona-restore.sh",
      mode    => '0700',
      owner   => 'root',
      group   => 'root',
      require     => File["${percona_restore_dir}/deidentify-db.sql"]
    }
    file { '${percona_restore_dir}/percona-restore-and-email.sh':
      ensure => present,
      source => 'puppet:///modules/percona/percona-restore-and-email.sh',
      path    => "${percona_restore_dir}/percona-restore-and-email.sh",
      mode    => '0700',
      owner   => 'root',
      group   => 'root',
      require     => File["${percona_restore_dir}/percona-restore.sh"]
    }
}
