class openmrs (

  $tomcat          = hiera('tomcat'),
  $tomcat_home_dir = hiera('tomcat_home_dir'),
  $webapp_name     = hiera('webapp_name')
) {

  package { 'p7zip-full' :
    ensure => 'installed'
  }

}