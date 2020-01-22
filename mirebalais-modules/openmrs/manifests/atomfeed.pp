class openmrs::atomfeed (
        $openmrs_modules_dir = hiera('openmrs_modules_dir'),
        $atomfeed_version = hiera('atomfeed_version'),
        $atomfeed_repo_url = hiera('atomfeed_repo_url'),
        $tomcat = hiera('tomcat')

) {

exec {'download_atomfeed_omod':
   command => "/usr/bin/wget -q ${atomfeed_repo_url}/atomfeed-${atomfeed_version}.omod -O  ${openmrs_modules_dir}/atomfeed-${atomfeed_version}.omod",
   require => Package['pihemr']

}

file { "atomfeed":
    path => "$openmrs_modules_dir/atomfeed-${atomfeed_version}.omod",
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => Exec['download_atomfeed_omod'],
    notify  => [ Exec['tomcat-restart'] ]
  }

}

