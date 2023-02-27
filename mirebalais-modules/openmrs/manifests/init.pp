class openmrs (

  $repo_url        = decrypt(hiera('repo_url')),
  $tomcat          = hiera('tomcat'),
  $tomcat_home_dir = hiera('tomcat_home_dir'),
  $webapp_name     = hiera('webapp_name')

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

}