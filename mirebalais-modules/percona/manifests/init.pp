class percona(
  $mysql_root_password = decrypt(hiera('mysql_root_password')),
) {

  wget::fetch { 'percona-release':
    source      => 'https://repo.percona.com/apt/percona-release_0.1-4.xenial_all.deb',
    destination => '/tmp',
    timeout     => 0,
    verbose     => false,
    before => Exec['install-percona-debian']
  }

  exec { 'install-percona-debian':
    command => "dpkg -i /tmp/percona-release_0.1-4.xenial_all.deb",
    user => root,
    refreshonly => true,
    before => Exec['percona-apt-get-update']
  }

  exec { 'percona-apt-get-update':
    refreshonly => true,
    command     => "apt-get update",
    before => Package['percona-xtrabackup']
  }

  package { 'percona-xtrabackup':
    ensure  => installed
  }

  mysql_user { "percona@localhost":
    ensure        => present,
    password_hash => mysql_password($mysql_root_password),
    require => [ Service['mysqld'] ],
  }

  mysql_grant { "percona@localhost/openmrs":
    options    => ['GRANT'],
    privileges => ['RELOAD', 'LOCK TABLES', 'REPLICATION CLIENT'],
    table => '*.*',
    user => "percona@localhost",
    require => [ Service['mysqld'] ],
  }

  mysql_grant { "percona@localhost/mysql":
    options    => ['GRANT'],
    privileges => ['RELOAD', 'LOCK TABLES', 'REPLICATION CLIENT'],
    table => '*.*',
    user => "percona@localhost",
    require => [ Service['mysqld'] ],
  }

}
