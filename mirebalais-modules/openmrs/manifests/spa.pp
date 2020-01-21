class openmrs::spa (
  $tomcat = hiera('tomcat')
) {

  package { 'unzip':
    ensure => installed,
  }

  $package_url = "http://bamboo.pih-emr.org/spa-repo/unstable/pih-spa-frontend.zip"

  exec{'download_and_install_spa_frontend':
    command => "/usr/bin/wget -q ${package_url} -O /tmp/pih-spa-frontend.zip && unzip -o /tmp/pih-spa-frontend.zip && rm -rf /home/${tomcat}/.OpenMRS/frontend && mv openmrs/frontend/ /home/${tomcat}/.OpenMRS/",
  }
}
