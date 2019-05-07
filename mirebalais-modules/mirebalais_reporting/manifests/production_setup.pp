class mirebalais_reporting::production_setup (
    $backup_db_user = decrypt(hiera('backup_db_user')),
    $backup_db_password = decrypt(hiera('backup_db_password')),
    $sysadmin_email = hiera('sysadmin_email'),
    $tomcat = hiera('tomcat')
  ){


  file { 'mirebalaisreportingdbdump.sh':
    ensure  => absent,    # disabling the old reporting dump solution in favor of the new one
    path    => '/usr/local/sbin/mirebalaisreportingdbdump.sh',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('mirebalais_reporting/mirebalaisreportingdbdump.sh.erb'),
  }

  # note that we don't install p7zip-full here because it is already installed as part of the openmrs main package

  cron { 'mysql-reporting-db-dump':
    ensure  => absent,    # disabling the old reporting dump solution in favor of the new one
    command => '/usr/local/sbin/mirebalaisreportingdbdump.sh >/dev/null',
    user    => 'root',
    hour    => 0,
    minute  => 00,
    environment => 'MAILTO=${sysadmin_email}',
    require => [ File['mirebalaisreportingdbdump.sh'], Package['p7zip-full'] ]
  }

  file { 'mirebalaisreportscleanup.sh':
    ensure => absent,    # disabling the old reporting dump solution in favor of the new one
    path => '/usr/local/sbin/mirebalaisreportscleanup.sh',
    mode => '0700',
    owner => 'root',
    group => 'root',
    content => template('mirebalais_reporting/mirebalaisreportscleanup.sh.erb')
  }

  cron { 'mirebalais-reports-cleanup':
    ensure => absent,    # disabling the old reporting dump solution in favor of the new one
    command => '/usr/local/sbin/mirebalaisreportscleanup.sh >/dev/null',
    user => 'root',
    hour =>	5,
    minute => 00,
    environment => 'MAILTO=${sysadmin_email}',
    require => [ File['mirebalaisreportscleanup.sh'] ]
  }



  file { 'mirebalais-production-percona-compress-db-and-scp.sh':
    ensure  => present,
    path    => '/usr/local/sbin/mirebalais-production-percona-compress-db-and-scp.sh',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('openmrs/mirebalais-production-percona-compress-db-and-scp.sh.erb'),
  }

  cron { 'mirebalais-production-percona-compress-db-and-scp':
    ensure  => present,
    command => '/usr/local/sbin/mirebalais-backup-reporting-db-n-tables-tables.sh >/dev/null 2>&1',
    user    => 'root',
    hour    => 20,
    minute  => 30,
    environment => 'MAILTO=${sysadmin_email}',
    require => [ File['mirebalais-production-percona-compress-db-and-scp.sh'] ]
  }

  file { 'mirebalais-production-percona-backup.sh':
    ensure  => present,
    path    => '/usr/local/sbin/mirebalaisreportingdbsource.sh',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('openmrs/mirebalais-production-percona-backup.sh.erb'),
  }

  cron { 'mirebalais-production-percona-backup':
    ensure  => present,
    command => '/usr/local/sbin/mirebalais-production-percona-backup.sh >/dev/null 2>&1',
    user    => 'root',
    hour    => 19,
    minute  => 00,
    environment => 'MAILTO=${sysadmin_email}',
    require => [ File['mirebalais-production-percona-backup.sh'] ]
  }
}
