class ntpdate(
  $timezone = hiera('server_timezone'),
  $server_1 = hiera('ntp_server_1'),
  $server_2 = hiera('ntp_server_2'),
  $server_3 = hiera('ntp_server_3'),
  $server_4 = hiera('ntp_server_4')
) {

  package { 'resolvconf':
    ensure => installed,
  }

  package { 'systemd-timesyncd':
    ensure => installed,
  }

  file { '/etc/resolvconf/resolv.conf.d/head':
    content => template('ntpdate/head.erb'),
    require => Package['resolvconf']
  }

  file { '/etc/resolvconf/resolv.conf.d/base':
    content => template('ntpdate/base.erb'),
    require => Package['resolvconf']
  }

  file { '/run/resolvconf/resolv.conf':
    content => template('ntpdate/resolv.conf.erb'),
    require => Package['resolvconf']
  }

  exec { "create a symbolic link for resolvconf":
    command => "ln -sf /run/resolvconf/resolv.conf /etc/resolv.conf",
    require => [ File["/run/resolvconf/resolv.conf"], File["/etc/resolvconf/resolv.conf.d/base"], File["/etc/resolvconf/resolv.conf.d/head"] ]
  }

  exec { "initialize resolvconf":
    command => "resolvconf -u",
      require => [ File["/run/resolvconf/resolv.conf"], File["/etc/resolvconf/resolv.conf.d/base"], File["/etc/resolvconf/resolv.conf.d/head"], Exec["create a symbolic link for resolvconf"]]
  }

  file { '/etc/systemd/timesyncd.conf':
    content => template('ntpdate/ntp.conf.erb'),
    require => [ Package['systemd-timesyncd']]
  }

  exec { "Set server to correct timezone":
    command => "timedatectl set-timezone ${timezone}",
    require => [ Package['systemd-timesyncd'], File['/etc/systemd/timesyncd.conf']]
  }

  file { '/etc/default/rcS':
    source => 'puppet:///modules/ntpdate/etc/rcS_default',
    require => [ Package['systemd-timesyncd'], Exec["Set server to correct timezone"]]
  }

  file { '/etc/timezone':
       ensure => present,
       content => "${timezone}\n",
       require => [ Package['systemd-timesyncd']]
  }

  service { 'systemd-timesyncd':
    ensure => running,
    enable => true,
    hasrestart => true,
    require => [ Package['systemd-timesyncd']]
  }
}
