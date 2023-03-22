## this file downloads distributions from the maven repository and extracts them in /tmp
## tested on malawi distribution
## Todo:- it could be used for Rwanda and the PIHEMR too after thorough testing

class openmrs::install_distribution_from_maven (

  $maven_download_repo      = hiera('maven_download_repo'),
  $maven_download_repo_package_group_id = hiera('maven_download_repo_package_group_id'),
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

}