class petl (
  $petl                        = hiera("petl"),
  $petl_version                = hiera("petl_version"),
  $petl_java_home              = hiera("petl_java_home"),
  $petl_java_opts              = hiera("petl_java_opts"),
  $petl_job_dir                = hiera("petl_job_dir"),
  $petl_datasource_dir         = hiera("petl_datasource_dir")
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

  # Set up scripts and services to execute PETL

  package { "openjdk-8-jdk":
    ensure  => present
  }

  file { "/home/$petl/bin/petl.sh":
    ensure  => present,
    content => template("petl/petl.sh.erb"),
    owner   => $petl,
    group   => $petl,
    mode    => "0755",
    require => [ File["/home/$petl/bin"], Package["openjdk-8-jdk"] ]
  }

  file { "/home/$petl/bin/petl.env":
    ensure  => present,
    content => template("petl/petl.env.erb"),
    owner   => $petl,
    group   => $petl,
    mode    => "0755",
    require => [ File["/home/$petl/bin"], Package["openjdk-8-jdk"] ]
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
