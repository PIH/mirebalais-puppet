class tomcat (
    $tomcat_home_dir = hiera('tomcat_home_dir'),
    $services_enable = hiera('services_enable'),
    $java_memory_parameters = hiera('java_memory_parameters'),
    $java_profiler = hiera('java_profiler'),
    $java_debug_parameters = hiera('java_debug_parameters'),
    $restart_nightly = hiera('tomcat_restart_nightly'),
    $enable_http_8080 = hiera('tomcat_enable_http_8080')
  ){




  package { 'tomcat7':
    ensure => purged
  }

  # TODO clean up ald tomcat directory and users

  user { 'tomcat':
    ensure => 'present',
    home   => "${tomcat_home_dir}",
    shell  => '/bin/sh',
  }

  file { $tomcat_home_dir:
    ensure  => directory,
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0755',
    require => User['tomcat']
  }

  exec { 'move-openmrs-home-directory':
    command => "mv /home/tomcat7/.OpenMRS ${tomcat_home_dir}",
    onlyif  => "test -d /home/tomcat7/.OpenMRS",
    require => file[$tomcat_home_dir],
    notify => Exec['change-home-directory-permissions']
  }

  exec { 'change-home-directory-permissions':
    command => "chown -R tomcat ${tomcat_home_dir}/.OpenMRS && chgrp -R tomcat ${tomcat_home_dir}/.OpenMRS",
    require => Exec['move-openmrs-home-directory'],
    refreshonly => true,
  }

  # install the proper version of tomcat via apt-get
  package { 'tomcat9' :
    ensure => installed,
    require => [ Package['openjdk-8-jdk'], Package['tomcat7'], User['tomcat']],
    notify  => Service['tomcat9']
  }

  # remove the "ROOT" webapp
  file { "/var/lib/tomcat9/webapps/ROOT":
    ensure  => absent,
    recurse => true,
    purge => true,
    force => true,
    require => Package['tomcat9']
  }

  file { "/etc/tomcat9/server.xml":
    ensure  => present,
    owner   => 'tomcat',
    group   => 'tomcat',
    content => template('tomcat/server.xml.erb'),
    require => [ Package['tomcat9'] ],
    notify  => Service['tomcat9']
  }

   file { "/etc/default/tomcat9":
    ensure  => file,
    content => template("tomcat/default.erb"),
    require => Package['tomcat9'],
    notify  => Service['tomcat9']
  }

  file { "/etc/logrotate.d/tomcat9":
    ensure  => file,
    source  => "puppet:///modules/tomcat/logrotate",

    notify  => Service['tomcat9']
  }

  # TODO: delete logging.properties if we remove this?
  /*
  file { "/var/lib/tomcat9/conf/logging.properties":
    ensure  => file,
    source  => "puppet:///modules/tomcat/logging.properties",
    require => Package['tomcat9'],
    notify  => Service['tomcat9']
  }
  */


  service { tomcat9:
    enable  => true,
    require => [ Package['tomcat9'], Package['openjdk-8-jdk'], File["/etc/tomcat9/server.xml"] ]
  }

  if $restart_nightly {
    cron { 'restart-tomcat':
      ensure  => present,
      command => "service tomcat9 restart > /dev/null",
      user    => 'root',
      hour    => 5,
      minute  => 00,
      require => [ Service['tomcat9'] ]
    }
  }
  else {
    cron { 'restart-tomcat':
      ensure  => absent
    }
  }

}
