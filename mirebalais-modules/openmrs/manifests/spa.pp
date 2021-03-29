class openmrs::spa (
  $tomcat = hiera('tomcat'),
  $spa_version = hiera('spa_version'),
  $config_name = hiera('config_name'),
  $webapp_name = hiera('webapp_name')
) {
  # Please see
  # https://pihemr.atlassian.net/wiki/spaces/PIHEMR/pages/555188230/CI+Release+and+Deployment
  # for more information about this process
if ($spa_version == 'ci') {
  # In CI, the server uses its own local frontend/assets directory, provided
  # by the configuration repo. The server is configured to pull the import map
  # from Bamboo. That import map refers to other files hosted in Bamboo.

  $config_suffix = regsubst($config_name, 'openmrs-config-', '')

  file { ["/home/${tomcat}/.OpenMRS/configuration/", "/home/${tomcat}/.OpenMRS/configuration/frontend"]:
    ensure  => directory,
    require => [ Exec['install-openmrs-configuration'] ]
  }

  file { "/home/${tomcat}/.OpenMRS/configuration/globalproperties":
    ensure  => directory,
    require => [ File["/home/${tomcat}/.OpenMRS/configuration"] ]
  }

  file { "/home/${tomcat}/.OpenMRS/configuration/globalproperties/spa-ci-gp.xml":
    ensure  => file,
    require => [ File["/home/${tomcat}/.OpenMRS/configuration/globalproperties"] ],
    content => template('openmrs/spa-ci-globalproperties.xml.erb'),
    notify  => [ Exec['tomcat-restart'] ]
  }

} else {
  # In a deployment, the bundle produced by Bamboo is deployed onto the server.

  $config_suffix = regsubst($config_name, 'openmrs-config-', '')
  $package_url = "http://bamboo.pih-emr.org:81/spa-repo/pih-spa-frontend/pih-spa-${config_suffix}-${spa_version}.zip"

  exec{'download_and_install_spa_frontend':
    command => "/usr/bin/wget -q ${package_url} -O /tmp/pih-spa-frontend.zip && unzip -o /tmp/pih-spa-frontend.zip && rm -rf /home/${tomcat}/.OpenMRS/configuration/frontend && mv openmrs/frontend/ /home/${tomcat}/.OpenMRS/configuration/",
    require => [ Exec['install-openmrs-configuration'],  Package['unzip'] ]
  }
}
}
