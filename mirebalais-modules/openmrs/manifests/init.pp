class openmrs (
    $openmrs_db = hiera('openmrs_db'),
    $openmrs_db_user = decrypt(hiera('openmrs_db_user')),
    $openmrs_db_password = decrypt(hiera('openmrs_db_password')),
    $openmrs_auto_update_database = hiera('openmrs_auto_update_database'),
    $package_release = hiera('package_release'),
    $webapp_name = hiera('webapp_name'),
    $tomcat = hiera('tomcat'),
    $junit_username = hiera('junit_username'),
    $junit_password = decrypt(hiera('junit_password')),
    $pih_config = hiera('pih_config'),
    $pih_config_array = split(hiera('pih_config'), ','),
    $config_dir = hiera('config_dir', undef),
    $activitylog_enabled = hiera('activitylog_enabled'),

    #Feature_toggles
    $reportingui_ad_hoc_analysis = hiera('reportingui_ad_hoc_analysis'),
    $radiology_contrast_studies = hiera('radiology_contrast_studies'),
    $appointmentscheduling_confidential= hiera('appointmentscheduling_confidential'),
    $insurance_collection = hiera('insurance_collection'),
    $additional_haiti_identifiers = hiera('additional_haiti_identifiers'),
    $htmlformentryui_simpleform_navbuttons = hiera('htmlformentryui_simpleform_navbuttons'),

    # Mirebalais only
    $remote_zlidentifier_url = hiera('remote_zlidentifier_url'),
    $remote_zlidentifier_username = decrypt(hiera('remote_zlidentifier_username')),
    $remote_zlidentifier_password = decrypt(hiera('remote_zlidentifier_password')),
    $lacolline_server_url = hiera('lacolline_server_url'),
    $lacolline_username = decrypt(hiera('lacolline_username')),
    $lacolline_password = decrypt(hiera('lacolline_password'))
  ){

  include openmrs::owa
  include openmrs::pwa

  package { 'p7zip-full' :
    ensure => 'installed'
  }

  file { '/etc/apt/apt.conf.d/99auth':
    ensure  => present,
    owner   => root,
    group   => root,
    content => 'APT::Get::AllowUnauthenticated yes;',
    mode    => '0644'
  }

  apt::source { 'pihemr':
    ensure      => present,
    location    => 'http://bamboo.pih-emr.org/pihemr-repo',
    release     => $package_release,
    repos       => '',
    include_src => false,
  }

  apt::source { 'mirebalais':
    ensure      => absent,
    location    => 'http://bamboo.pih-emr.org/mirebalais-repo',
    release     => $package_release,
    repos       => '',
    include_src => false,
  }

  package { 'pihemr':
    ensure  => latest,
    require => [ Package[$tomcat], Service[$tomcat], Service['mysqld'], Apt::Source['pihemr'],
      File["/home/${tomcat}/.OpenMRS/${webapp_name}-runtime.properties"], File['/etc/apt/apt.conf.d/99auth'] ],
  }

  file { "/home/${tomcat}/.OpenMRS":
    ensure  => directory,
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0755',
    require => User[$tomcat]
  }

  # added this to handle reworking off application data directory in Core 2.x
  file { "/home/${tomcat}/.OpenMRS/${webapp_name}":
    ensure  => 'link',
    owner   => $tomcat,
    group   => $tomcat,
    target  => "/home/${tomcat}/.OpenMRS"
  }

  file { "/home/${tomcat}/.OpenMRS/feature_toggles.properties":
    ensure  => present,
    content => template('openmrs/feature_toggles.properties.erb'),
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => File["/home/${tomcat}/.OpenMRS"]
  }

  file { "/home/${tomcat}/.OpenMRS/${webapp_name}-runtime.properties":
    ensure  => present,
    content => template('openmrs/openmrs-runtime.properties.erb'),
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => File["/home/${tomcat}/.OpenMRS"]
  }


  # bit of hack to install up to 5 config files; we should switch to using a loop once we upgrade to version of puppet that supports that
  if ($pih_config_array[0] != undef) {
    file { "/home/${tomcat}/.OpenMRS/pih-config-${pih_config_array[0]}.json":
      ensure  => present,
      source  => "puppet:///modules/openmrs/config/pih-config-${pih_config_array[0]}.json",
      owner   => $tomcat,
      group   => $tomcat,
      mode    => '0644',
      require => File["/home/${tomcat}/.OpenMRS"]
    }
  }

  if ($pih_config_array[1] != undef) {
    file { "/home/${tomcat}/.OpenMRS/pih-config-${pih_config_array[1]}.json":
      ensure  => present,
      source  => "puppet:///modules/openmrs/config/pih-config-${pih_config_array[1]}.json",
      owner   => $tomcat,
      group   => $tomcat,
      mode    => '0644',
      require => File["/home/${tomcat}/.OpenMRS"]
    }
  }


  if ($pih_config_array[2] != undef) {
    file { "/home/${tomcat}/.OpenMRS/pih-config-${pih_config_array[2]}.json":
      ensure  => present,
      source  => "puppet:///modules/openmrs/config/pih-config-${pih_config_array[2]}.json",
      owner   => $tomcat,
      group   => $tomcat,
      mode    => '0644',
      require => File["/home/${tomcat}/.OpenMRS"]
    }
  }


  if ($pih_config_array[3] != undef) {
    file { "/home/${tomcat}/.OpenMRS/pih-config-${pih_config_array[3]}.json":
      ensure  => present,
      source  => "puppet:///modules/openmrs/config/pih-config-${pih_config_array[3]}.json",
      owner   => $tomcat,
      group   => $tomcat,
      mode    => '0644',
      require => File["/home/${tomcat}/.OpenMRS"]
    }
  }

  if ($pih_config_array[4] != undef) {
    file { "/home/${tomcat}/.OpenMRS/pih-config-${pih_config_array[4]}.json":
      ensure  => present,
      source  => "puppet:///modules/openmrs/config/pih-config-${pih_config_array[4]}.json",
      owner   => $tomcat,
      group   => $tomcat,
      mode    => '0644',
      require => File["/home/${tomcat}/.OpenMRS"]
    }
  }

  /* Add the configuration/ directory to the application data directory,
     according to the parameter `config_dir` */
  if ($config_dir != undef) {
    file { "/home/${tomcat}/.OpenMRS/configuration":
      ensure  => directory,
      recurse => 'remote',
      source  => "puppet:///modules/openmrs/app-data-config/${config_dir}/configuration",
      owner   => $tomcat,
      group   => $tomcat,
      mode    => '0644',
      require => [ File["/home/${tomcat}/.OpenMRS"] ]
    }
  }

  exec { 'tomcat-restart':
    command     => "service ${tomcat} restart",
    user        => 'root',
    refreshonly => true
  }

   # this is legacy, this is now handled by our custom app loader factor
   file { "/home/${tomcat}/.OpenMRS/appframework-config.json":
	ensure => absent
   }

}
