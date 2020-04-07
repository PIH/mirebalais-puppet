class openmrs::spa (
  $tomcat = hiera('tomcat'),
  $spa_ci = hiera('spa_ci'),
  $config_name = hiera('config_name')
) {
  # Please see
  # https://pihemr.atlassian.net/wiki/spaces/PIHEMR/pages/555188230/CI+Release+and+Deployment
  # for more information about this process
if ($spa_ci) {
  # In CI, the import map is located on the server, but refers to modules which
  # are served by Apache on the Bamboo server. The site-specific assets also
  # are copied onto the server.

  file { "/home/${tomcat}/.OpenMRS/frontend":
    ensure => directory
  }

  file { "/home/${tomcat}/.OpenMRS/frontend/import-map.json":
    ensure  => file,
    source  => 'puppet:///modules/openmrs/import-map.ci.json',
    require => [ Package[$tomcat], File["/home/${tomcat}/.OpenMRS/frontend"] ]
  }

  if ($config_name != '') {

    exec { 'add_config_file_to_import_map':
      require =>  File["/home/${tomcat}/.OpenMRS/frontend/import-map.json"],
      command => "sed -i 's/\"react\":/\"config-file\": \"https://github.com/PIH/${config_name}/blob/master/frontend/assets/config.json\",\n      \"react\":/' /home/${tomcat}/.OpenMRS/frontend/import-map.json",
      onlyif  => "grep -q config-file /home/${tomcat}/.OpenMRS/frontend/import-map.json"
    }

    $config_url = "https://github.com/PIH/${config_name}/archive/master.zip"

    wget::fetch { 'download-openmrs-configuration':
      source      => config_url,
      destination => "/tmp/${config_name}.zip",
      timeout     => 0,
      verbose     => false,
      redownload  => true,
    }

    exec{'install-openmrs-config-frontend':
      command => "rm -rf /tmp/configuration && unzip -o /tmp/${config_name}.zip -d /tmp/configuration && rm -rf /home/${tomcat}/.OpenMRS/frontend && mkdir /home/${tomcat}/.OpenMRS/frontend && mv /tmp/configuration/frontend/* /home/${tomcat}/.OpenMRS/frontend",
      require => [ Wget::Fetch['download-openmrs-configuration'], Package['unzip'], File["/home/${tomcat}/.OpenMRS"] ]
    }
  }

} else {
  # In a deployment, the bundle produced by Bamboo is deployed onto the server.

  $config_suffix = regsubst($config_name, 'openmrs-config-', '')
  $package_url = "https://bamboo.pih-emr.org:81/spa-repo/pih-spa-frontend/unstable/pih-spa-frontend-${config_suffix}.zip"

  exec{'download_and_install_spa_frontend':
    command => "/usr/bin/wget -q ${package_url} -O /tmp/pih-spa-frontend.zip && unzip -o /tmp/pih-spa-frontend.zip && rm -rf /home/${tomcat}/.OpenMRS/configuration/frontend && mv openmrs/frontend/ /home/${tomcat}/.OpenMRS/configuration/",
    require => [ Package['unzip'] ]
  }
}
}
