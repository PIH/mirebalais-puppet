class openmrs::atomfeed (
        $openmrs_modules_dir  = hiera('openmrs_modules_dir'),
        $atomfeed_version     = hiera('atomfeed_version'),
        $atomfeed_repo_url    = hiera('atomfeed_repo_url'),
        $tomcat               = hiera('tomcat'),
        $package_name = hiera('package_name')
) {

  exec {'download_atomfeed_omod':
   command => "/usr/bin/wget -q ${atomfeed_repo_url}/org/openmrs/module/atomfeed-omod/${atomfeed_version}/atomfeed-omod-${atomfeed_version}.jar -O  ${openmrs_modules_dir}/atomfeed-${atomfeed_version}.omod",
   require => Package[$package_name]
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
