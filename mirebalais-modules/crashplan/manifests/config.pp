class crashplan(
  $services_ensure = hiera('services_ensure'),
  $services_enable = hiera('services_enable'),
){

  Exec['install'] {
        path +> ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin']
  }

  exec { 'install':
    cwd     => '/usr/local/CrashPlanPRO-install',
    command => '/usr/local/CrashPlanPRO-install/install.sh',
    require => [ File['/usr/local/CrashPlanPRO-install/install.sh'] ],
  }

  file_line { 'Modify my.service.xml':
    path  => '/usr/local/crashplan/conf/my.service.xml',  
    line  => '<serviceHost>0.0.0.0</serviceHost>',
    match => '^<serviceHost>127.0.0.1</serviceHost>',
    ensure  => present,
    require => [ Exec['install'] ],
  }

  file { '/usr/local/CrashPlanPro-install/install.sh':
    ensure  => present,
    path    => '/usr/local/CrashPlanPro-install/install.sh',
  }

  if $services_enable {
    $require = [ File['/etc/init.d/crashplan'], File['/usr/local/crashplan/bin/CrashPlanEngine'], File['/usr/local/crashplan/conf/my.service.xml'] ] 
  } 

  service { 'crashplan':
    ensure   => $services_ensure,
    enable   => $services_enable,
    provider => upstart,
    require  => $require
  }
}
