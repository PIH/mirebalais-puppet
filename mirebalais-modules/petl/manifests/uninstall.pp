class petl::uninstall (
  $petl = hiera("petl")
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

  file { "/home/$petl":
    ensure  => absent,
    force   => true,
    require => Service[$petl]
  }

  user { "$petl":
    ensure  => "absent",
    require => File["/home/$petl"]
  }

  group { "$petl":
    ensure  => "absent",
    require => User[$petl]
  }
}
