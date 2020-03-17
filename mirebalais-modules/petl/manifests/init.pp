class petl (
  $petl                   = hiera("petl_user"),
  $version                = hiera("petl_version"),
  $java_memory_parameters = hiera("java_memory_parameters")
) {

  # Setup Group, User, and Home Directory for PETL installation

  group { "$petl":
    ensure => "present"
  }

  user { "$petl":
    ensure  => "present",
    home    => "/home/$petl",
    shell   => "/bin/bash",
    groups  => ["$petl"],
    require => Group["$petl"]
  }

  file { "/home/$petl":
    ensure  => directory,
    owner   => "$petl",
    group   => "$petl",
    mode    => "0755",
    require => User["$petl"]
  }

  # Setup Logging

  file { "/home/$petl/logs":
    ensure  => directory,
    owner   => "$petl",
    group   => "$petl",
    mode    => "0755",
    require => File["/home/$petl"]
  }

  file { "/etc/logrotate.d/$petl":
    ensure  => file,
    source  => "puppet:///modules/petl/logrotate",
    require => File["/home/$petl/logs"],
    notify  => Service[$petl]
  }

  # Setup work and data directories

  file { "/home/$petl/data":
    ensure  => directory,
    owner   => "$petl",
    group   => "$petl",
    mode    => "0755",
    require => File["/home/$petl"]
  }

  file { "/home/$petl/work":
    ensure  => directory,
    owner   => "$petl",
    group   => "$petl",
    mode    => "0755",
    require => File["/home/$petl"]
  }

  # Setup application binaries

  file { "/home/$petl/bin":
    ensure  => directory,
    owner   => "$petl",
    group   => "$petl",
    mode    => "0755",
    require => File["/home/$petl"]
  }

  wget::fetch { "download-petl-jar":
    source      => "http://bamboo.pih-emr.org/artifacts/petl-$petl_version.jar",
    destination => "/home/$petl/bin/petl.jar",
    timeout     => 0,
    verbose     => false,
    require => File["/home/$petl/bin"]
  }

  # Set up scripts and services to start PETL

  # Option 1, try to set this up using system V
  # See:  https://docs.spring.io/spring-boot/docs/1.3.1.RELEASE/reference/html/deployment-install.html#deployment-initd-service

  file { "/etc/init.d/$petl" :
    ensure => 'link',
    target => "/home/$petl/bin/petl.jar",
  }



  # Another option, similar to what we did with pih-biometrics a while back

  file { "/home/$petl/bin/petl.sh":
    ensure  => present,
    content => template("petl/peth.sh.erb"),
    owner   => $petl,
    group   => $petl,
    mode    => "0755",
    require => File["/home/$petl/bin"]
  }

  file { "/etc/init.d/$petl":
    ensure  => present,
    content => template("petl/service-init.erb"),
    mode    => "0755",
    require => File["/home/$petl/bin/petl.sh"]
  }

  exec { 'petl-startup-enable':
    command     => "/usr/sbin/update-rc.d -f $petl defaults 81",
    user        => 'root',
    refreshonly => true,
    require => File["/etc/init.d/$petl"]
  }

  service { $petl:
    enable  => true,
    require => Exec["petl-startup-enable"]
  }

}
