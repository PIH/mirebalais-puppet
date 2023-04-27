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

  package { 'ntp':
    ensure => installed,
  }

  package { 'ntpdate':
    ensure => installed,
    require => Package['ntp']
  }

  file { '/etc/resolvconf/resolv.conf.d/head':
    content => template('ntpdate/head.erb'),
    require => Package['resolvconf']
  }

  file { '/etc/resolvconf/resolv.conf.d/base':
    content => template('ntpdate/base.erb'),
    require => Package['resolvconf']
  }

  file { '/etc/resolv.conf':
    content => template('ntpdate/resolv.conf.erb'),
    require => Package['resolvconf']
  }

  exec { "initialize resolvconf":
    command => "resolvconf -u",
      require => [ File["/etc/resolv.conf"], File["/etc/resolvconf/resolv.conf.d/base"], File["/etc/resolvconf/resolv.conf.d/head"] ]
  }

  file { '/etc/ntp.conf':
    content => template('ntpdate/ntp.conf.erb'),
    require => [ Package['ntp'], Package['ntpdate'] ]
  }

  file { '/etc/default/rcS':
    source => 'puppet:///modules/ntpdate/etc/rcS_default',
    require => [ Package['ntp'], Package['ntpdate'] ]
  }

  file { '/etc/timezone':
       ensure => present,
       content => "${timezone}\n",
       require => [ Package['ntp'], Package['ntpdate'] ]
  }

  exec { 'stop ntp':
    command     => 'service ntp stop',
    subscribe   => [ File['/etc/ntp.conf'], File['/etc/timezone'], File['/etc/default/rcS'] ],
    refreshonly => true,
    require => [ Package['ntp'], Package['ntpdate'] ]
  }

  exec { 'update time':
    command     => 'ntpdate-debian',
    subscribe   => Exec['stop ntp'],
    refreshonly => true,
    require => [ Package['ntp'], Package['ntpdate'], Exec['initialize resolvconf'] ]
  }

  exec { 'start ntp':
    command     => 'service ntp start',
    subscribe   => Exec['update time'],
    refreshonly => true,
    require => [ Package['ntp'], Package['ntpdate'], Exec['initialize resolvconf'] ]
  }
}

