class java (
  $tomcat = hiera('tomcat')
){

  file { '/etc/environment':
    source => 'puppet:///modules/java/etc/environment'
  }

  # install OpenJDK 8
  package { 'openjdk-8-jdk':
    ensure  => present,
    require => [File['/etc/environment']]
  }

  exec { "update-java-alternatives -s java-1.8.0-openjdk-amd64":
    path    => ["/usr/bin", "/usr/sbin"],
    subscribe => Package["openjdk-8-jdk"],
    refreshonly => true
  }

  # TODO there was a little funkiness here that made me need to do the following two steps manually; this may need to be tweaked in the future
  exec { "rm -f /usr/lib/jvm/default-java":
    subscribe => Package["openjdk-8-jdk"],
    refreshonly => true
  }

  exec { "ln -sf /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/default-java":
    notify => Service[$tomcat],
    subscribe => Exec["rm -f /usr/lib/jvm/default-java"],
    refreshonly => true
  }

}