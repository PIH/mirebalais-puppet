class logging (
  $smtp_username = decrypt(hiera('smtp_username')),
  $smtp_userpassword = decrypt(hiera('smtp_userpassword'))
){

  file { '/etc/logstash/conf.d/logstash.conf':
    ensure  => file,
    content => template('logging/logstash.conf.erb'),
    require => File['/etc/logstash/conf.d'],
    notify  => Service['logstash']
  }

  class { 'logstash':
    provider     => 'custom',
    jarfile      => 'puppet:///modules/logging/logstash-1.1.9-monolithic.jar',
    installpath  => '/usr/local/logstash',
    defaultsfile => 'puppet:///modules/logging/logstash_default'
  }
}
