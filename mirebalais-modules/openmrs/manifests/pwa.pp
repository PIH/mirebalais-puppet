class openmrs::pwa (

  $pwa_config_name =  hiera('pwa_config_name'),
  $pwa_config_url =  hiera('pwa_config_url'),
  $pwa_config_version       = hiera('pwa_config_version'),
  $pwa_webapp_name       = hiera('pwa_webapp_name'),
  $pwa_enabled        = hiera('pwa_enabled'),
  $tomcat          = hiera('tomcat'),
  $tomcat_webapp_dir = hiera('tomcat_webapp_dir'),

) {

  # currently supports only a single PWA per site, we will need update this long-term

  # TODO: once we upgrade to Puppet 4.4+ we can just specific the file as as source (and therefore may not need exec wget and download every run)
  # TODO: come up with a more streamlined way to do this & handle versioning and whether we are installing a "stable" version or not, whether to switch Adds On and Bamboo, etc

  # remove old pwa.tar.gz directory
  exec { 'remove old pwa dir':
    command => "rm -rf /tmp/${pwa_config_name}.tar.gz && rm -rf /tmp/${pwa_config_name}.tar",
  }

  # remove old pwa directory in the webapp folder
  exec {  'remove old pwa directory in the webapp folder':
    command  => "rm -rf ${tomcat_webapp_dir}/${pwa_webapp_name}",
  }

  # download new pwa.tar.gz directory
  wget::fetch { 'download-pwa-configuration-dir':
      source      => "${pwa_config_url}",
      destination => "/tmp/${pwa_config_name}.tar.gz",
      timeout     => 0,
      verbose     => false,
      redownload => true,
      require => [Exec['remove old pwa dir'], Exec['remove old pwa directory in the webapp folder']]
    }

  # extract pwa.tar.gz
  exec { 'extract pwa using gunzip':
    command => "gunzip /tmp/${pwa_config_name}.tar.gz",
    cwd     => "/tmp",
    user    => root,
    group   => root,
    require => Wget::Fetch['download-pwa-configuration-dir']
  }

  # extract the new pwa folder into the webapp folder
  exec { 'extract pwa using tar':
    command => "tar -xvf /tmp/${pwa_config_name}.tar",
    cwd     => "${tomcat_webapp_dir}",
    user    => $tomcat,
    group   => $tomcat,
    require => Exec['extract pwa using gunzip'],
  }

  # set owner to Tomcat
  file { "${tomcat_webapp_dir}/${pwa_webapp_name} ":
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => Exec['extract pwa using tar'],
  }
}