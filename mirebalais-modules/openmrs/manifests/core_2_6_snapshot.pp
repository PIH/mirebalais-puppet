
# temporary hack to install the current OpenMRS 2.6 core snapshot war for dispensing testing
# note that currently hardcoded to the most recent snapshot as of Oct 28, 2022; we can change as nededed
class openmrs::core_2_6_snapshot {
  wget::fetch { 'core-2_6-snapshot-download':
    source      => 'https://openmrs.jfrog.io/artifactory/snapshots/org/openmrs/web/openmrs-webapp/2.6.0-SNAPSHOT/openmrs-webapp-2.6.0-20221028.143812-235.war',
    destination => '/tmp/openmrs-webapp-2.6.0-20221028.143812-235.war'
  }

  exec{'core-2_6-snapshot-install':
    command => "rm /var/lib/tomcat7/webapps/openmrs.war && rm -rf /var/lib/tomcat7/webapps/openmrs && cp /tmp/openmrs-webapp-2.6.0-20221028.143812-235.war /var/lib/tomcat7/webapps/openmrs.war",
    require => [ Wget::Fetch['core-2_6-snapshot-download'], Package[$package_name] ],
    notify => Exec['tomcat-restart']
  }

}


