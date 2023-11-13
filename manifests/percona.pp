Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }

node 'hai-hum-inf-omrs-report' {
  include docker
  include percona::install_restore_scripts
  class { 'percona::setup_cron_to_refresh_openmrs_db':
    site_name => 'haiti/mirebalais',
    percona_restore_deidentify => false
  }
}