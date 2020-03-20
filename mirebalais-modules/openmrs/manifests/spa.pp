class openmrs::spa (
  $tomcat = hiera('tomcat'),
  $spa_ci = hiera('spa_ci')
) {
if ($spa_ci) {
  file { "/home/${tomcat}/.OpenMRS/frontend":
    ensure => directory
  }

  file { "/home/${tomcat}/.OpenMRS/frontend/import-map.json":
    ensure  => file,
    source  => 'puppet:///modules/openmrs/import-map.ci.json',
    require => [ Package[$tomcat], File["/home/${tomcat}/.OpenMRS/frontend"] ]
  }
} else {
  $package_url = 'https://bamboo.pih-emr.org:81/spa-repo/pih-spa-frontend/unstable/pih-spa-frontend.zip'

  exec{'download_and_install_spa_frontend':
    command => "/usr/bin/wget -q ${package_url} -O /tmp/pih-spa-frontend.zip && unzip -o /tmp/pih-spa-frontend.zip && rm -rf /home/${tomcat}/.OpenMRS/frontend && mv openmrs/frontend/ /home/${tomcat}/.OpenMRS/",
    require => [ Package['unzip'] ]
  }
}
}
