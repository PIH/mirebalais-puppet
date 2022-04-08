class petl::uninstall_service (
  $petl                        = hiera("petl"),
  $petl_home_dir               = hiera("petl_home_dir")
) {


  exec { 'stop-petl':
    command     => "/etc/init.d/$petl stop",
    user        => 'root'
  }

  exec { 'delete /etc/init.d/petl file' :
    command => "rm -rf /etc/init.d/petl",
    require => Exec['stop-petl']
  }

  exec { 'remove petl startup files':
    command => "rm -rf /etc/rc0.d/K01petl && rm -rf /etc/rc1.d/K01petl && rm -rf /etc/rc2.d/S03petl && rm -rf /etc/rc3.d/S03petl && rm -rf /etc/rc4.d/S03petl && rm -rf /etc/rc5.d/S03petl && rm -rf /etc/rc6.d/K01petl",
    require => [Exec['stop-petl'], Exec['delete /etc/init.d/petl file']]
  }

}
