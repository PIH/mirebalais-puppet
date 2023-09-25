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
    ensure  => present,
    command => '/home/percona/scripts/mirebalais-percona-backup.sh >/dev/null 2>&1',
    user    => 'root',
    hour    => 21,
    minute  => 00,
    environment => "MAILTO=$sysadmin_email",
    require => [ File['mirebalais-percona-backup.sh'] ]
  }

  # this has been added to the end of the backup script
  cron { 'mirebalais-percona-transfer-to-reporting-nightly':
    ensure  => absent
  }

  cron { 'mirebalais-percona-transfer-to-humtest-weekly':
    ensure  => present,
    command => 'scp -v -r /home/percona/backups/openmrs root@192.168.1.18:/home/reporting/percona/backups > /home/percona/logs/scp_humtest.log 2>&1',
    user    => 'root',
    weekday => 6,
    hour    => 0,
    minute  => 5,
    environment => "MAILTO=$sysadmin_email",
    require => [ File['mirebalais-percona-backup.sh'] ]
  }
}
