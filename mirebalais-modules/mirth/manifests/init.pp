class mirth(
  $mirth_db = hiera('mirth_db'),
  $mirth_db_user = decrypt(hiera('mirth_db_user')),
  $mirth_db_password = decrypt(hiera('mirth_db_password')),
  $services_ensure = hiera('services_ensure'),
  $services_enable = hiera('services_enable'),
  $openmrs_db = hiera('openmrs_db'),
  $package_name = hiera('package_name')
){

  mysql_database { $mirth_db :
    ensure  => present,
    charset => 'utf8',
    require => [Service['mysqld'], Package[$package_name]],
  }

  mysql_user { "${mirth_db_user}@localhost":
    ensure        => present,
    password_hash => mysql_password($mirth_db_password),
    require       => Service['mysqld'],
  } ->

  mysql_grant { "${mirth_db_user}@localhost/${mirth_db}":
    options    => ['GRANT'],
    privileges => ['ALL'],
    table => '*.*',
    user => "${mirth_db_user}@localhost",
    require    => Service['mysqld'],
  } ->

  mysql_grant { "root@localhost/${mirth_db}":
    options    => ['GRANT'],
    privileges => ['ALL'],
    table => '*.*',
    user => "root@localhost",
    require    => Service['mysqld'],
  }

  mysql_grant { "${mirth_db_user}@localhost/${openmrs_db}.pacsintegration_outbound_queue":
    options    => ['GRANT'],
    privileges => ['ALL'],
    table => '*.*',
    user => "${mirth_db_user}@localhost",
    require    => [ Service['mysqld'], Mysql_database[$openmrs_db] ]
  }

  file {'/usr/local/mirthconnect':
    ensure => directory,
    owner  => 'root',
    group  => 'root'
  }

  wget::fetch { 'download-mirth':
    source      => 'http://downloads.mirthcorp.com/connect/2.2.1.5861.b1248/mirthconnect-2.2.1.5861.b1248-unix.tar.gz',
    destination => '/usr/local/mirth.tgz',
    timeout     => 0,
    verbose     => false,
  }

  exec { 'mirth-unzip':
    cwd     => '/usr/local',
    command => 'tar -C mirthconnect --strip-components=1 -xzf /usr/local/mirth.tgz',
    unless  => 'test -f /usr/local/mirthconnect/mcservice',
    require => [ Wget::Fetch['download-mirth'], File['/usr/local/mirthconnect'] ],
  }

  file {'/usr/local/mirthconnect/logs':
    ensure  => directory,
    require => Exec['mirth-unzip']
  }

  file {'/usr/local/mirthconnect/appdata':
    source  => 'puppet:///modules/mirth/appdata',
    recurse => true,
    require => Exec['mirth-unzip']
  }

  file { '/usr/local/mirthconnect/conf/mirth.properties':
    ensure  => present,
    content => template('mirth/mirth.properties.erb'),
    require => Exec['mirth-unzip']
  }

  file { '/etc/init.d/mcservice':
    ensure  => link,
    target  => '/usr/local/mirthconnect/mcservice',
    require => Exec['mirth-unzip']
  }

  file { '/etc/systemd/system/mcservice.service':
    ensure  => file,
    source  => 'puppet:///modules/mirth/etc/systemd/system/mcservice.conf',
  }

  service { 'mcservice':
    ensure   => true,
    enable   => true,
    require  => [ File['/etc/init.d/mcservice'], File['/usr/local/mirthconnect/conf/mirth.properties'], File['/usr/local/mirthconnect/appdata'], Mysql_database[$mirth_db] ]
  }
}
