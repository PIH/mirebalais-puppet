class petl::java (
) {
  package { "openjdk-8-jdk":
    ensure => present
  }

  exec { "Hack to support multiple petl service on one server":
    command => "cp -r /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/java-8-openjdk-amd64-2",
    require => Package['openjdk-8-jdk'],
  }
}