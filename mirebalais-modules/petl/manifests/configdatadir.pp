class petl::configdatadir(

  $petl =           hiera("petl"),
  $petl_base_dir =  hiera("petl_base_dir"),
  $petl_site =      hiera('petl_site'),
  $petl_user =      hiera("petl_user"),
  $petl_job_dir =   hiera("petl_job_dir"),
  $petl_config_dir_url =  hiera('petl_config_dir_url'),
  $petl_config_name =     hiera('petl_config_name'),
  $config_version =       hiera('config_version')

){

  if('pih-pentaho' in $petl_config_name)  {
    vcsrepo { '/opt/${petl_base_dir}/${petl_job_dir}"':
      ensure   => latest,
      provider => git,
      source      => "${petl_config_dir_url}",
      require => Service["$petl"],
      notify => Exec['petl-restart']
    }
  }
  else {
    $config_url = "https://oss.sonatype.org/service/local/artifact/maven/content?g=org.pih.openmrs&a=${config_name}&r=${config_repo}&p=zip&v=${config_version}"

    wget::fetch { 'download-openmrs-config-dir':
      source      => "${config_url}",
      destination => "/tmp/${config_name}.zip",
      timeout     => 0,
      verbose     => false,
      redownload => true,
    }

    exec{'install-openmrs-config-dir':
      command => "rm -rf /tmp/configuration && unzip -o /tmp/${config_name}.zip -d /tmp/configuration && rm -rf /opt/$petl_base_dir &&
      mkdir /opt/$petl_base_dir && cp -r /tmp/configuration/* /opt/$petl_base_dir/jobs",
      require => [ Wget::Fetch['download-openmrs-config-dir'], Package['unzip'], Service["$petl"]],
      notify => Exec['petl-restart']
    }
  }

}
