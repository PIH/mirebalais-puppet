## this file downloads configuration from the maven repository and extracts them in /tmp
## tested on malawi distribution

class openmrs::install_config_from_maven (

  $config_name     = hiera('config_name'),
  $config_version  = hiera('config_version'),
  $maven_download_repo      = hiera('maven_download_repo'),
  $maven_download_repo_config_group_id = hiera('maven_download_repo_config_group_id')

) {
  ## for malawi, this is used to download the configuration file log4j
  ## ideally, this block could be omitted and added to Exec['cleanup-openmrs-maven-distribution-dir'] but its only specific for Apzu. In the future we may need to
  ## add an if condition to these blocks
  exec { 'cleanup-downloaded-openmrs-config-dirs':
    command => "rm -rf /tmp/${config_name}-${config_version}.zip && rm -rf /tmp/${config_name}-${config_version}"
  }

  maven { "/tmp/${config_name}-${config_version}.zip":
    groupid => "${maven_download_repo_config_group_id}",
    artifactid => "${config_name}",
    version => "${config_version}",
    ensure => latest,
    packaging => zip,
    repos => "${maven_download_repo}",
    require => [Exec['cleanup-downloaded-openmrs-config-dirs'], Package['maven']],
  }

  exec { 'extract-downloaded-config-dir':
    command => "unzip -o /tmp/${config_name}-${config_version}.zip -d /tmp/${config_name}-${config_version}",
    require => [Maven["/tmp/${config_name}-${config_version}.zip"], Package['unzip']]
  }

}