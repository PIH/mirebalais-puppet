Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }

node default {
}

node 'emr.hum.ht' {
  include mirebalais_reporting::production_setup
}

node 'hai-hum-inf-omrs-report' {
  include mirebalais_reporting::reporting_setup
}
