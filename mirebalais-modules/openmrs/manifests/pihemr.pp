class openmrs::pihemr (

  $openmrs_db                    = hiera('openmrs_db'),
  $openmrs_db_user               = decrypt(hiera('openmrs_db_user')),
  $openmrs_db_password           = decrypt(hiera('openmrs_db_password')),
  $cc_user_name                  = decrypt(hiera('commcare_user')),
  $cc_user_password              = decrypt(hiera('commcare_password')),
  $openmrs_auto_update_database  = hiera('openmrs_auto_update_database'),
  $package_name                  = hiera('package_name'),
  $package_release               = hiera('package_release'),
  $package_version               = hiera('package_version'),
  $webapp_name                   = hiera('webapp_name'),
  $tomcat                        = hiera('tomcat'),
  $tomcat_home_dir               = hiera('tomcat_home_dir'),
  $tomcat_webapp_dir             = hiera('tomcat_webapp_dir'),
  $junit_username                = hiera('junit_username'),
  $junit_password                = decrypt(hiera('junit_password')),
  $pih_config                    = hiera('pih_config'),
  $config_dir                    = hiera('config_dir', undef),
  $activitylog_enabled           = hiera('activitylog_enabled'),
  $terms_and_conditions_enabled  = hiera('terms_and_conditions_enabled'),
  $session_timeout               = hiera('session_timeout'),

  # PIH EMR config
  $config_name     = hiera('config_name'),
  $config_version  = hiera('config_version'),
  $pihemr_debian_repo_url        = hiera('pihemr_debian_repo_url'),
  $ocl_package_url = hiera('ocl_package_url'),

  # Frontend
  $frontend_name  = hiera('frontend_name'),
  $frontend_version = hiera('frontend_version'),

  #Feature_toggles
  $reportingui_ad_hoc_analysis            = hiera('reportingui_ad_hoc_analysis'),
  $radiology_contrast_studies             = hiera('radiology_contrast_studies'),
  $appointmentscheduling_confidential     = hiera('appointmentscheduling_confidential'),
  $insurance_collection                   = hiera('insurance_collection'),
  $htmlformentryui_simpleform_navbuttons  = hiera('htmlformentryui_simpleform_navbuttons'),
  # Mirebalais only
  $remote_zlidentifier_url      = hiera('remote_zlidentifier_url'),
  $remote_zlidentifier_username = decrypt(hiera('remote_zlidentifier_username')),
  $remote_zlidentifier_password = decrypt(hiera('remote_zlidentifier_password')),
  $haiti_hiv_emr_link_url       = decrypt(hiera('haiti_hiv_emr_link_url')),

  # e-mail config
  $smtp_username = decrypt(hiera('smtp_username')),
  $smtp_userpassword = decrypt(hiera('smtp_userpassword')),
  $smtp_mailhub = decrypt(hiera('smtp_mailhub')),

) {


  apt::source { $package_name:
    ensure      => present,
    location    => "[trusted=yes] ${pihemr_debian_repo_url}",
    release     => $package_release,
    repos       => 'main',
    include_src => false,
  }


  # if we are using unstable repo (ie for ci servers) always use latest, otherwise use version specified by package release
  $pihemr_version = $package_release ? {
    /unstable/ => 'latest',
    default    =>  $package_version,
  }

  file { "${tomcat_home_dir}/.OpenMRS":
    ensure  => directory,
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644'
  }


  file { "${tomcat_home_dir}/.OpenMRS/modules":
    ensure  => directory,
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => File["${tomcat_home_dir}/.OpenMRS"]
  }

  # added this to handle reworking of application data directory in Core 2.x
  file { "${tomcat_home_dir}/.OpenMRS/${webapp_name}":
    ensure  => 'link',
    owner   => $tomcat,
    group   => $tomcat,
    target  => "/home/${tomcat}/.OpenMRS"
  }

  # remove any hold on package (if it exists) (grep -c returns line count, so mimics true/false)
  exec { 'package_unhold':
    command => "apt-mark unhold ${package_name}",
    user => 'root',
    onlyif => "apt-mark showhold | grep -c ${package_name}",
    require => Apt::Source[$package_name],
  }

  # prevent inadvertent upgrade when manually running "apt-get upgrade" (without specifying package name)
  exec { 'package_hold':
    command => "apt-mark hold ${package_name}",
    user => 'root',
    require => Package[$package_name]
  }

  file { "${tomcat_home_dir}/.OpenMRS/feature_toggles.properties":
    ensure  => present,
    content => template('openmrs/feature_toggles.properties.erb'),
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => File["${tomcat_home_dir}/.OpenMRS"]
  }

  file { "${tomcat_home_dir}/.OpenMRS/${webapp_name}-runtime.properties":
    ensure  => present,
    content => template('openmrs/openmrs-runtime.properties.erb'),
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0600',
    require => File["${tomcat_home_dir}/.OpenMRS"]
  }

  package { $package_name:
    ensure  => $pihemr_version,
    install_options => [ '--allow-change-held-packages' ],
    require => [ Package[$tomcat], Service[$tomcat], Service['mysqld'], Exec['package_unhold'],
      File["${tomcat_home_dir}/.OpenMRS/${webapp_name}-runtime.properties"] ],
  }

  # Adds session-timeout in the session-config block. If there's no existing session-config block, we're in trouble.
  exec { "web_xml_session_timeout_sed":
    require =>  Package[$package_name],
    command => "sed -i 's/<session-config>.*$/<session-config><session-timeout>${session_timeout}<\/session-timeout>/' ${tomcat_webapp_dir}/${webapp_name}/WEB-INF/web.xml",
    onlyif => "test -f ${tomcat_webapp_dir}/${webapp_name}/WEB-INF/web.xml"
  }

  if ($config_name != "") {

    if ('SNAPSHOT' in $config_version) {
      $config_repo = "snapshots"
    }
    else {
      $config_repo = "releases"
    }

    $config_url = "https://s01.oss.sonatype.org/service/local/artifact/maven/content?g=org.pih.openmrs&a=${config_name}&r=${config_repo}&p=zip&v=${config_version}"

    # TODO can we change this so it only redownloads if needed?
    wget::fetch { 'download-openmrs-configuration':
      source      => "${config_url}",
      destination => "/tmp/${config_name}.zip",
      timeout     => 0,
      verbose     => false,
      redownload => true,
    }

    exec{'install-openmrs-configuration':
      command => "rm -rf /tmp/configuration && unzip -o /tmp/${config_name}.zip -d /tmp/configuration && rm -rf ${tomcat_home_dir}/.OpenMRS/configuration && mkdir ${tomcat_home_dir}/.OpenMRS/configuration && cp -r /tmp/configuration/* ${tomcat_home_dir}/.OpenMRS/configuration",
      require => [ Wget::Fetch['download-openmrs-configuration'], Package['unzip'], File["${tomcat_home_dir}/.OpenMRS"] ],
      notify => [ Exec['tomcat-restart'] ]
    }

    # TODO This can be removed once we fully migrate to OCL.  This exists to allow testing OCL package installation as a replacement for MDS
    if ($ocl_package_url != "") {

        file { "${tomcat_home_dir}/.OpenMRS/configuration/ocl/":
            ensure  => directory,
            owner   => $tomcat,
            group   => $tomcat,
            mode    => '0644',
            require => Exec['install-openmrs-configuration']
        }

        exec{'remove-existing-ocl-packages':
          command => "rm -rf ${tomcat_home_dir}/.OpenMRS/configuration/ocl/*",
          require => File["${tomcat_home_dir}/.OpenMRS/configuration/ocl/"]
        }

        wget::fetch { 'download-ocl-package-zip':
          source      => "${ocl_package_url}",
          destination => "${tomcat_home_dir}/.OpenMRS/configuration/ocl/PIH.zip",
          timeout     => 0,
          verbose     => false,
          redownload  => true,
          require     => Exec["remove-existing-ocl-packages"]
        }

        exec{'remove-mds-concept-packages':
          command => "rm -rf ${tomcat_home_dir}/.OpenMRS/configuration/pih/concepts/*",
          require => Wget::Fetch["download-ocl-package-zip"],
          notify => [ Exec['tomcat-restart'] ]
        }
    }
  }

  if ($frontend_name != "") {

    if ('SNAPSHOT' in $frontend_version) {
      $frontend_repo = "snapshots"
    }
    else {
      $frontend_repo = "releases"
    }

    $frontend_url = "https://s01.oss.sonatype.org/service/local/artifact/maven/content?g=org.pih.openmrs&a=${frontend_name}&r=${frontend_repo}&p=zip&v=${frontend_version}"

    # TODO can we change this so it only redownloads if needed?
    wget::fetch { 'download-openmrs-frontend':
      source      => $frontend_url,
      destination => "/tmp/${frontend_name}.zip",
      timeout     => 0,
      verbose     => false,
      redownload  => true,
    }

    exec{'install-openmrs-frontend':
      command => "rm -rf /tmp/frontend && unzip -o /tmp/${frontend_name}.zip -d /tmp/frontend && rm -rf /home/${tomcat}/.OpenMRS/frontend && mkdir /home/${tomcat}/.OpenMRS/frontend && cp -r /tmp/frontend/*/* /home/${tomcat}/.OpenMRS/frontend",
      require => [ Wget::Fetch['download-openmrs-frontend'], Package['unzip'], File["/home/${tomcat}/.OpenMRS"] ]
    }

    # hack to change webapp name in the frontend application after it has already been built into the deb
    exec { 'fix spa application webapp name':
      unless  => "test ${webapp_name} = openmrs",
      command => "sed -i 's/\/openmrs\([\/\"]\)/\/${webapp_name}\1/g' ${tomcat_home_dir}/.OpenMRS/frontend/index.html",
      require => Exec['install-openmrs-frontend']
    }

  }

  if ($config_name != '' and $frontend_name != '') {
    exec{ 'link-configuration-into-frontend':
      command => "ln -s ../configuration/frontend /home/${tomcat}/.OpenMRS/frontend/site",
      require => [ Exec['install-openmrs-frontend'], Exec['install-openmrs-configuration'] ]
    }
  }

  # this is legacy, this is now handled by our custom app loader factor
  file { "${tomcat_home_dir}/.OpenMRS/appframework-config.json":
    ensure => absent
  }

  # hack to enable activity log
  if ($activitylog_enabled == true)  {
    file { "${tomcat_home_dir}/.OpenMRS/configuration/log4j2.xml":
        ensure  => present,
        content => template('openmrs/log4j2.xml.erb'),
        owner   => root,
        group   => root,
        mode    => '0644',
        require => File["${tomcat_home_dir}/.OpenMRS"]
      }
    }

  exec { 'tomcat-restart':
    command     => "service ${tomcat} restart",
    user        => 'root',
    refreshonly => true
  }

}
