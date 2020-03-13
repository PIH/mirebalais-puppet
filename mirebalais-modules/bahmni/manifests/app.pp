class bahmni::app (
  $tomcat = hiera('tomcat')
){

  file { "/var/lib/${tomcat}/webapps/bahmniapps":
    ensure  => directory,
    require => [Service[$tomcat]] ,
  }

  # TODO make this something that relies on a true deployment process, and allows use to apply updates
  # TODO right now it will only work the first time through
  wget::fetch { 'download-bahmniapps':
    source      => 'https://bamboo.pih-emr.org:81/bahmni-repo/bahmniapps.tar.gz',
    destination => "/var/lib/${tomcat}/webapps/bahmniapps/bahmniapps.tar.gz",
    timeout     => 0,
    verbose     => false,
    require => File["/var/lib/${tomcat}/webapps/bahmniapps"]
  }

  exec { 'unzip_bahmniapps':
    cwd     => "/var/lib/${tomcat}/webapps/bahmniapps",
    command => 'gzip -d bahmniapps.tar.gz',
    refreshonly => true,
    subscribe => [ Wget::Fetch['download-bahmniapps'] ]
  }

  exec { 'untar_bahmniapps':
    cwd     => "/var/lib/${tomcat}/webapps/bahmniapps",
    command => 'tar -xf bahmniapps.tar',
    refreshonly => true,
    subscribe => [ Exec['unzip_bahmniapps'] ]
  }
}
