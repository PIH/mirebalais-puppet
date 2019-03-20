class tomcat (
    $tomcat = hiera('tomcat'),
    $services_enable = hiera('services_enable'),
    $java_memory_parameters = hiera('java_memory_parameters'),
    $java_profiler = hiera('java_profiler'),
    $java_debug_parameters = hiera('java_debug_parameters'),
    $restart_nightly = hiera('tomcat_restart_nightly')
  ){

  # TODO--remove these three purges after tomcat7 apt-get update has been installed on all servers
  # make sure old versions instaled without apt-get have been removed
  file { "/usr/local/apache-tomcat-6.0.36" :
    ensure => absent,
    recurse => true,
    purge => true,
    force => true,
  }

  file { "/usr/local/apache-tomcat-7.0.62" :
    ensure => absent,
    recurse => true,
    purge => true,
    force => true,
  }

  file { "/usr/local/apache-tomcat-7.0.68" :
    ensure => absent,
    recurse => true,
    purge => true,
    force => true,
  }

  file { "/usr/local/$tomcat" :
    ensure => absent,
    recurse => true,
    purge => true,
    force => true,
  }

  # TODO--remove these three purges after tomcat7 apt-get update has been installed on all servers
  # config files are removed, **but only when removing old tomcat**
  exec { 'remove /etc/init.d/tomcat':
    command     => "rm /etc/init.d/$tomcat",
    subscribe   => [ File["/usr/local/apache-tomcat-6.0.36"], File["/usr/local/apache-tomcat-7.0.62"], File["/usr/local/apache-tomcat-7.0.68"]],
    refreshonly => true,
  }

  exec { 'remove /etc/default/tomcat':
    command     => "rm /etc/default/$tomcat",
    subscribe   => [ File["/usr/local/apache-tomcat-6.0.36"], File["/usr/local/apache-tomcat-7.0.62"], File["/usr/local/apache-tomcat-7.0.68"]],
    refreshonly => true,
  }

  exec { 'remove /etc/logrotate.d/tomcat':
    command     => "rm /etc/logrotate.d/$tomcat",
    subscribe   => [ File["/usr/local/apache-tomcat-6.0.36"], File["/usr/local/apache-tomcat-7.0.62"], File["/usr/local/apache-tomcat-7.0.68"]],
    refreshonly => true,
  }

  # install the proper version of tomcat via apt-get
  package { $tomcat :
    ensure => installed,
    require => [ User[$tomcat], File["/usr/local/apache-tomcat-6.0.36"], File["/usr/local/apache-tomcat-7.0.62"], File["/usr/local/apache-tomcat-7.0.68"],
        Exec['remove /etc/init.d/tomcat'], Exec['remove /etc/default/tomcat'], Exec['remove /etc/logrotate.d/tomcat']],
    notify  => Service["$tomcat"]
  }

  # remove the "ROOT" webapp
  file { "/var/lib/$tomcat/webapps/ROOT":
    ensure  => absent,
    recurse => true,
    purge => true,
    force => true,
    require => Package[$tomcat]
  }


  file { "/etc/${tomcat}/server.xml":
    ensure  => present,
    owner   => $tomcat,
    group   => $tomcat,
    source  => "puppet:///modules/tomcat/server.xml",
    require => [ Package[$tomcat], User[$tomcat] ],
    notify  => Service[$tomcat]
  }

   file { "/etc/default/${tomcat}":
    ensure  => file,
    content => template("tomcat/default.erb"),
    require => Package[$tomcat],
    notify  => Service[$tomcat]
  }

  file { "/etc/logrotate.d/${tomcat}":
    ensure  => file,
    source  => "puppet:///modules/tomcat/logrotate",
    require => Package[$tomcat],
    notify  => Service[$tomcat]
  }

  file { "/var/lib/${tomcat}/conf/logging.properties":
    ensure  => file,
    source  => "puppet:///modules/tomcat/logging.properties",
    require => Package[$tomcat],
    notify  => Service[$tomcat]
  }


  user { $tomcat:
    ensure => 'present',
    home   => "/home/${tomcat}",
    shell  => '/bin/sh',
  }

  file { "/home/${tomcat}":
    ensure  => directory,
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0755',
    require => User[$tomcat]
  }

  # todo add a dependency on java being installed?
  service { $tomcat:
    enable  => true,
    require => [ Package[$tomcat], Package['openjdk-7-jdk'], File["/etc/${tomcat}/server.xml"] ]
  }

  if $restart_nightly {
    cron { 'restart-tomcat':
      ensure  => present,
      command => "service ${tomcat} restart",
      user    => 'root',
      hour    => 5,
      minute  => 00,
      require => [ Service[$tomcat] ]
    }
  }
  else {
    cron { 'restart-tomcat':
      ensure  => absent
    }
  }

}
