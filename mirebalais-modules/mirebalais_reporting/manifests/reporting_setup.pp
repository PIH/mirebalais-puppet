class mirebalais_reporting::reporting_setup (
	$openmrs_db = hiera('openmrs_db'),
	$openmrs_db_user = decrypt(hiera('openmrs_db_user')),
	$openmrs_db_password = decrypt(hiera('openmrs_db_password')),
	$openmrs_warehouse_db = decrypt(hiera('openmrs_warehouse_db')),
	$mysql_root_password = decrypt(hiera('backup_db_password')),
	$sysadmin_email = hiera('sysadmin_email'),
	$perconaHomeDir = hiera('perconaHomeDir'),
	$perconaReportDir = hiera('perconaReportDir'),
	$perconaBackupDir = hiera('perconaBackupDir'),
	$perconaLogs = hiera('perconaLogs'),
	$perconaLogFile = hiera('perconaLogFile'),
	$perconaRestoreDir = hiera('perconaRestoreDir'),
	$perconaSite = hiera('perconaSite'),
	$mysqlDb = hiera('mysqlDb'),
	$reportingTables = hiera('reportingTables'),
	$reportingDumps = hiera('reportingDumps'),
	$minPerconaDirSize = hiera('minPerconaDirSize')
) {

	# note that public/private key sharing needs to be set up manually between production and reporting
   user { backups:
     ensure => 'present',
     home   => "/home/backups",
     shell  => '/bin/bash',
   }
   
   file { "${perconaBackupDir}":
     ensure  => directory,
     owner   => root,
     group   => root,
     mode    => '0755',
   }
   
   file { 'percona-openmrs-db-restore.sh':
     ensure  => present,
     path    => "${perconaHomeDir}/scripts/percona-openmrs-db-restore.sh",
     mode    => '0700',
     owner   => 'root',
     group   => 'root',
     content => template('mirebalais_reporting/percona-openmrs-db-restore.sh.erb'),
   }
   
   file { 'restore-reporting-table.sh':
     ensure  => present,
     path    => "${perconaHomeDir}/scripts/restore-reporting-table.sh",
     mode    => '0700',
     owner   => 'root',
     group   => 'root',
     content => template('mirebalais_reporting/restore-reporting-table.sh.erb'),
   }
   
   cron { 'percona-openmrs-db-restore':
     ensure  => present,
     command => "${perconaHomeDir}/scripts/percona-openmrs-db-restore.sh >/dev/null 2>&1",
     user    => 'root',
     hour    => 02,
     minute  => 30,
     environment => "MAILTO=$sysadmin_email",
     require => [ File['percona-openmrs-db-restore.sh'] ]
   }
   
   cron { 'restore-reporting-table':
     ensure  => present,
     command => "${perconaHomeDir}/scripts/restore-reporting-table.sh >/dev/null 2>&1",
     user    => 'root',
     hour    => 05,
     minute  => 00,
     environment => "MAILTO=$sysadmin_email",
     require => [ File['restore-reporting-table.sh'] ]
   }
}
