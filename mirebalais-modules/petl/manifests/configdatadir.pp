class petl::configdatadir(
  $petl             = hiera("petl"),
  $petl_home_dir    = hiera("petl_home_dir"),
  $petl_site        = hiera('petl_site'),
  $petl_user        = hiera("petl_user"),
  $petl_job_dir     = hiera("petl_job_dir"),
  $pih_etl_repo_url = hiera('pih_etl_repo_url'),
  $config_name      = hiera('config_name'),
  $config_repo      = hiera('config_repo'),
  $config_version   = hiera('config_version')

){

  if('pih-pentaho' in $petl_etl_git_repo)  {
    vcsrepo { "${petl_home_dir}/${petl_job_dir}":
      ensure   => latest,
      provider => git,
      source      => "${pih_etl_repo_url}",
      require => Service["$petl"],
      notify => Exec['petl-restart']
    }
  }
  else {
    wget::fetch { 'download-openmrs-config-dir':
      source      => "${pih_etl_repo_url}",
      destination => "/tmp/petl_${config_name}.zip",
      timeout     => 0,
      verbose     => false,
      redownload => true,
    }

    exec{'install-openmrs-config-dir':
      command => "rm -rf /tmp/configuration && unzip -o /tmp/petl_${config_name}.zip -d /tmp/configuration && rm -rf /opt/$petl_home_dir &&
      mkdir /opt/$petl_home_dir && cp -r /tmp/configuration/* /opt/$petl_home_dir/jobs",
      require => [ Wget::Fetch['download-openmrs-config-dir'], Package['unzip'], Service["$petl"]],
      notify => Exec['petl-restart']
    }
  }

}