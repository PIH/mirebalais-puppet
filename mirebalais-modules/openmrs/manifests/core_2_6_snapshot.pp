
# temporary hack to install the current OpenMRS 2.6 core snapshot war for dispensing testing
# note that currently hardcoded to the most recent snapshot as of Oct 28, 2022; we can change as nededed
class openmrs::core_2_6_snapshot {
  wget::fetch { 'core_2_6_snapshot_download':
    source      => 'https://openmrs.jfrog.io/artifactory/snapshots/org/openmrs/web/openmrs-webapp/2.6.0-SNAPSHOT/openmrs-webapp-2.6.0-20221028.143812-235.war',
    destination => '/var/lib/tomcat7/webapps/openmrs.war',
    redownload  => true,
    require => Package[$package_name],
    notify => Exec['tomcat-restart']
  }
}


