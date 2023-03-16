## this file downloads and extracts the openmrs distribution and configuration file for malawi
## it could be used for Rwanda and the PIHEMR too (note: this statement isn't tested and Rwanda doesn't have the log4j config file yet)

class openmrs::download_artifacts_from_maven_repo (

  $config_name     = hiera('config_name'),
  $config_version  = hiera('config_version'),
  $maven_download_repo      = hiera('maven_download_repo'),
  $maven_download_repo_package_group_id = hiera('maven_download_repo_package_group_id'),
  $maven_download_repo_config_group_id = hiera('maven_download_repo_config_group_id'),
  $package_name     = hiera('package_name'),
  $package_version  = hiera('package_version'),

) {

  # ensure that old distributions in /tmp don't exist
  exec { 'cleanup-openmrs-maven-distribution-dir':
   command => "rm -rf /tmp/${package_name}-${package_version}.zip && rm -rf /tmp/${package_name}-${package_version}"
  }

  # dowload new distribution from maven repo
  maven { "/tmp/${package_name}-${package_version}.zip":
    groupid => "${maven_download_repo_package_group_id}",
    artifactid => "${package_name}",
    version => "${package_version}",
    ensure => latest,
    packaging => zip,
    repos => "${maven_download_repo}",
    require => [Exec['cleanup-openmrs-maven-distribution-dir'], Package['maven']],
  }

  # extract the new
  exec { 'extract-distro':
    command => "unzip -o /tmp/${package_name}-${package_version}.zip -d /tmp",
    require => [ Exec['cleanup-openmrs-maven-distribution-dir'], Maven["/tmp/${package_name}-${package_version}.zip"], Package['unzip']]
  }

  ## this is for the configuration file log4j
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