class openmrs::spa (
  $tomcat = hiera('tomcat')
) {

  $package_url = "https://bamboo.pih-emr.org:81/spa-repo/unstable/pih-spa-frontend.zip"

  exec{'download_and_install_spa_frontend':
    command => "/usr/bin/wget -q ${package_url} -O /tmp/pih-spa-frontend.zip && unzip -o /tmp/pih-spa-frontend.zip && rm -rf /home/${tomcat}/.OpenMRS/frontend && mv openmrs/frontend/ /home/${tomcat}/.OpenMRS/",
    require => [ Package['unzip'] ]
  }
}
