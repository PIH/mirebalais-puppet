class openmrs (

  $tomcat          = hiera('tomcat'),
  $tomcat_home_dir = hiera('tomcat_home_dir'),

){

  file { '/etc/apt/apt.conf.d/99auth':
    ensure  => present,
    owner   => root,
    group   => root,
    content => 'APT::Get::AllowUnauthenticated yes;',
    mode    => '0644'
  }

  package { 'p7zip-full' :
    ensure => 'installed'
  }

  file { "${tomcat_home_dir}/.OpenMRS":
    ensure => directory,
    owner  => $tomcat,
    group  => $tomcat,
    require => File["${tomcat_home_dir}"]
  }

}
