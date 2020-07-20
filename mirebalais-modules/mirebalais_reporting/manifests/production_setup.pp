class mirebalais_reporting::production_setup (
    $backup_db_user = decrypt(hiera('backup_db_user')),
    $backup_db_password = decrypt(hiera('backup_db_password')),
    $percona_password = decrypt(hiera('percona_password')),
    $sysadmin_email = hiera('sysadmin_email'),
    $tomcat = hiera('tomcat')
  ){

  file { 'mirebalais-percona-backup.sh':
    ensure  => present,
    path    => '/home/percona/scripts/mirebalais-percona-backup.sh',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('mirebalais_reporting/mirebalais-percona-backup.sh.erb'),
  }

  file { 'mirebalais-percona-delete-dir.sh':
    ensure  => present,
    path    => '/home/percona/scripts/mirebalais-percona-delete-dir.sh',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('mirebalais_reporting/mirebalais-percona-delete-dir.sh.erb'),
  }

  cron { 'mirebalais-percona-backup':
    ensure  => present,
    command => '/home/percona/scripts/mirebalais-percona-backup.sh >/dev/null 2>&1',
    user    => 'root',
    hour    => 21,
    minute  => 00,
    environment => 'MAILTO=${sysadmin_email}',
    require => [ File['mirebalais-percona-backup.sh'] ]
  }

  cron { 'Copy percona backup over to reporting':
    ensure  => present,
    command => 'scp -r /home/percona/backups/openmrs root@192.168.1.217:/home/reporting/percona/backups > /tmp/scp.log',
    user    => 'root',
    hour    => 23,
    minute  => 00,
    environment => 'MAILTO=${sysadmin_email}',
    require => [ File['mirebalais-percona-backup.sh'] ]
  }

  cron { 'mirebalais-percona-delete-dir':
      ensure  => present,
      command => '/home/percona/scripts/mirebalais-percona-delete-dir.sh >/dev/null 2>&1',
      user    => 'root',
      hour    => 02,
      minute  => 30,
      environment => 'MAILTO=${sysadmin_email}',
      require => [ File['mirebalais-percona-delete-dir.sh'] ]
    }
}
