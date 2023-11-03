class mirebalais_reporting::production_setup (
    $backup_db_user = decrypt(hiera('backup_db_user')),
    $backup_db_password = decrypt(hiera('backup_db_password')),
    $percona_password = decrypt(hiera('percona_password')),
    $sysadmin_email = decrypt(hiera('sysadmin_email'))
){

  file { 'mirebalais-percona-backup.sh':
    ensure  => present,
    path    => '/home/percona/scripts/mirebalais-percona-backup.sh',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('mirebalais_reporting/mirebalais-percona-backup.sh.erb'),
  }

  cron { 'mirebalais-percona-backup':
    ensure  => absent
  }

  # this has been added to the end of the backup script
  cron { 'mirebalais-percona-transfer-to-reporting-nightly':
    ensure  => absent
  }

  cron { 'mirebalais-percona-transfer-to-humtest-weekly':
    ensure => absent
  }
}
