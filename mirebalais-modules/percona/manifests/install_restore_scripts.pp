class percona::install_restore_scripts (
    $percona_restore_dir               = decrypt(hiera('percona_restore_dir')),
    $backup_password                   = decrypt(hiera('backup_db_password')),
    $az_url                            = decrypt(hiera('az_url')),
    $az_secret                         = decrypt(hiera('az_secret')),
    $tomcat_user                       = decrypt(hiera('tomcat')),
    $tomcat_home_dir                   = decrypt(hiera('tomcat_home_dir')),
    $sysadmin_email                    = hiera('sysadmin_email')
  ) {
    file { '/root/.percona.env':
      ensure  => present,
      path    => '/root/.percona.env',
      mode    => '0700',
      owner   => 'root',
      group   => 'root',
      content => template('percona/percona.env.erb'),
    }
    file { "${percona_restore_dir}":
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => '0755',
      require     => File["/root/.percona.env"]
    }
    file { '${percona_restore_dir}/percona-restore.sh':
      ensure => present,
      source => 'puppet:///modules/percona/percona-restore.sh',
      path    => "${percona_restore_dir}/percona-restore.sh",
      mode    => '0700',
      owner   => 'root',
      group   => 'root',
      require     => File["${percona_restore_dir}"]
    }
    file { '${percona_restore_dir}/deidentify-db.sql':
      ensure => present,
      source => 'puppet:///modules/percona/deidentify-db.sql',
      path    => "${percona_restore_dir}/deidentify-db.sql",
      mode    => '0700',
      owner   => 'root',
      group   => 'root',
      require     => File["${percona_restore_dir}/percona-restore.sh"]
    }
    file { '${percona_restore_dir}/deidentify-db.sh':
      ensure => present,
      source => 'puppet:///modules/percona/deidentify-db.sh',
      path    => "${percona_restore_dir}/deidentify-db.sh",
      mode    => '0700',
      owner   => 'root',
      group   => 'root',
      require     => File["${percona_restore_dir}/deidentify-db.sql"]
    }
}