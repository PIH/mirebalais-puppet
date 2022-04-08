class petl::uninstall_service (
  $petl = hiera("petl")
) {

  require petl

  exec { 'stop-petl':
    command     => "/etc/init.d/$petl stop",
    user        => 'root'
  }

  service { $petl:
    ensure  => false,
    enable  => false,
    hasstatus => true,
    require => Exec[$petl]
  }

  file { "/etc/init.d/$petl" :
    ensure => 'absent',
    require => Service['stop-petl']
  }
}
