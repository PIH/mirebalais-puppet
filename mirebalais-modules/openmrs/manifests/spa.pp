class openmrs::spa (
  $tomcat = hiera('tomcat'),
  $spa_ci = hiera('spa_ci'),
  $config_name = hiera('config_name')
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

  exec { 'add_config_file_to_import_map':
    require =>  File["/home/${tomcat}/.OpenMRS/frontend/import-map.json"],
    command => "sed -i 's/\"react\":/\"config-file\": \"https://github.com/PIH/${config_name}/blob/master/frontend/assets/config.json\",\n      \"react\":/' /home/${tomcat}/.OpenMRS/frontend/import-map.json",
    onlyif  => "grep -q config-file /home/${tomcat}/.OpenMRS/frontend/import-map.json"
  }

  


} else {
  $config_suffix = regsubst($config_name, 'openmrs-config-', '')
  $package_url = "https://bamboo.pih-emr.org:81/spa-repo/pih-spa-frontend/unstable/pih-spa-frontend-${config_suffix}.zip"

  exec{'download_and_install_spa_frontend':
    command => "/usr/bin/wget -q ${package_url} -O /tmp/pih-spa-frontend.zip "
      + '&& unzip -o /tmp/pih-spa-frontend.zip '
      + "&& rm -rf /home/${tomcat}/.OpenMRS/frontend && mv openmrs/frontend/ /home/${tomcat}/.OpenMRS/",
    require => [ Package['unzip'] ]
  }
}
}
