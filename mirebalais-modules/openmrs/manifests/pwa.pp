class openmrs::pwa (
  $tomcat = hiera('tomcat'),
  $tomcat_webapp_dir = hiera('tomcat_webapp_dir'),
  $package_release = hiera('package_release'),
  $pwa_enabled = hiera('pwa_enabled'),
  $pwa_filename = hiera('pwa_filename'),
  $pwa_webapp_name = hiera('pwa_webapp_name')
) {

  # currently supports only a single PWA per site, we will need update this long-term

  # TODO: once we upgrade to Puppet 4.4+ we can just specific the file as as source (and therefore may not need exec wget and download every run)
  # TODO: come up with a more streamlined way to do this & handle versioning and whether we are installing a "stable" version or not, whether to switch Adds On and Bamboo, etc

  if ($pwa_enabled) {
    # install PWA from bamboo
    exec { 'retrieve_pwa':
      command => "/usr/bin/wget -q https://bamboo.pih-emr.org:81/pwa-repo/${package_release}${pwa_filename} -O ${tomcat_webapp_dir}/${pwa_filename}",
      require => Service["$tomcat"]
    }

    # remove old directory
    file { "${tomcat_webapp_dir}/${pwa_webapp_name}":
      ensure   => absent,
      recurse => true,
      force => true,
      require => Exec['retrieve_pwa']
    }

    # set owner to Tomcat
    file { "${tomcat_webapp_dir}/${pwa_filename}":
      owner   => $tomcat,
      group   => $tomcat,
      mode    => '0644',
      require => File["${tomcat_webapp_dir}/${pwa_webapp_name}"],
    }

    exec { 'extract pwa' :
      command => "tar -xvf ${tomcat_webapp_dir}/${pwa_filename}",
      cwd => "${tomcat_webapp_dir}",
      user   => $tomcat,
      group   => $tomcat,
      require => File["${tomcat_webapp_dir}/${pwa_filename}"],
      notify  => Exec['tomcat-restart']
    }
  }


}

