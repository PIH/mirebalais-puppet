class ntpdate(
  $timezone = hiera('server_timezone'),
) {

  package { 'ntp':
    ensure => installed,
  }

  package { 'ntpdate':
    ensure => installed,
    require => Package['ntp']
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
    require => [ Package['ntp'], Package['ntpdate'] ]
  }

  exec { 'start ntp':
    command     => 'service ntp start',
    subscribe   => Exec['update time'],
    refreshonly => true,
    require => [ Package['ntp'], Package['ntpdate'] ]
  }
}
