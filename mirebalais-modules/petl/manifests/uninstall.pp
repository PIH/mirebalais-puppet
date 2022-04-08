class petl::uninstall (
  $petl = hiera("petl"),
  $petl_home_dir = hiera("petl_home_dir")
) {

  service { $petl:
    ensure  => false,
    enable  => false,
    hasstatus => true
  }

  file { "/etc/init.d/$petl" :
    ensure => 'absent',
    require => Service[$petl]
  }

  exec { 'service-reload':
    command     => "systemctl daemon-reload",
    user        => 'root',
    require => File["/etc/init.d/$petl"]
  }

  file { $petl_home_dir:
    ensure  => absent,
    force   => true,
    require => Service[$petl]
  }

  user { "$petl":
    ensure  => "absent",
    require => File[$petl_home_dir]
  }

  group { "$petl":
    ensure  => "absent",
    require => User[$petl]
  }
}