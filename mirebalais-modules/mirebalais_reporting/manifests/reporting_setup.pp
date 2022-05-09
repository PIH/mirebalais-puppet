class mirebalais_reporting::reporting_setup (
	$openmrs_db = hiera('openmrs_db'),
	$openmrs_db_user = decrypt(hiera('openmrs_db_user')),
	$openmrs_db_password = decrypt(hiera('openmrs_db_password')),
	$openmrs_warehouse_db = decrypt(hiera('openmrs_warehouse_db')),
	$backup_db_password = decrypt(hiera('backup_db_password')),
	$sysadmin_email = hiera('sysadmin_email'),
	$perconaHomeDir = hiera('perconaHomeDir'),
  $perconaBackupDir = hiera('perconaBackupDir'),
	$perconaLogs = hiera('perconaLogs'),
	$perconaRestoreDir = hiera('perconaRestoreDir'),
	$perconaSite = hiera('perconaSite'),

	$mysqlDb = hiera('mysqlDb'),
	$reportingTables = hiera('reportingTables'),
	$reportingDumps = hiera('reportingDumps'),

	$minPerconaDirSize = hiera('minPerconaDirSize')

) {

	# note that public/private key sharing needs to be set up manually between production and reporting
	user {
		backups:
    		ensure => 'present',
    		home   => "/home/backups",
    		shell  => '/bin/bash',
  	}

	file { "${perconaHomeDir}":
		ensure  => directory,
		owner   => root,
		group   => root,
		mode    => '0755',
		require =>  Package['percona-xtrabackup']
	}

	file { "${perconaHomeDir}/scripts":
		ensure  => directory,
		owner   => root,
		group   => root,
		mode    => '0755',
		require =>  File["${perconaHomeDir}"]
	}

	file { "${perconaBackupDir}"
		ensure  => directory,
		owner   => root,
		group   => root,
		mode    => '0755',
		require =>  File["${perconaHomeDir}"]
	}

	file { 'mirebalaisreportingdbsource.sh':
		ensure  => absent,
		path    => '/usr/local/sbin/mirebalaisreportingdbsource.sh',
		mode    => '0700',
		owner   => 'root',
		group   => 'root',
		content => template('mirebalais_reporting/mirebalaisreportingdbsource.sh.erb'),
	}

	file { 'mirebalaiswarehousedbdump.sh':
		ensure  => absent,
		path    => '/usr/local/sbin/mirebalaiswarehousedbdump.sh'
	}

	cron { 'mirebalais-reporting-db-source':
		ensure  => absent,
		command => '/usr/local/sbin/mirebalaisreportingdbsource.sh >/dev/null 2>&1',
		user    => 'root',
		hour    => 18,
		minute  => 00,
		environment => "MAILTO=$sysadmin_email",
		require => [ File['mirebalaisreportingdbsource.sh'], Package['p7zip-full'] ]
	}


	file { 'mirebalais-warehouse-n-reporting-tables.sh':
		ensure  => present,
		path    => "${perconaHomeDir}/scripts/mirebalais-warehouse-n-reporting-tables.sh",
		mode    => '0700',
		owner   => 'root',
		group   => 'root',
		content => template('mirebalais_reporting/mirebalais-warehouse-n-reporting-tables.sh.erb'),
	}

	file { 'percona-openmrs-db-restore.sh':
		ensure  => present,
		path    => "${perconaHomeDir}/scripts/percona-openmrs-db-restore.sh",
		mode    => '0700',
		owner   => 'root',
		group   => 'root',
		content => template('mirebalais_reporting/percona-openmrs-db-restore.sh.erb'),
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

	cron { 'mirebalais-warehouse-n-reporting-tables.sh':
		ensure  => present,
		command => "${perconaHomeDir}/scripts/mirebalais-warehouse-n-reporting-tables.sh >/dev/null 2>&1",
		user    => 'root',
		hour    => 03,
		minute  => 50,
		environment => "MAILTO=$sysadmin_email",
		require => [ File['mirebalais-warehouse-n-reporting-tables.sh'] ]
	}

	file { "/usr/local/sbin/restart-server.sh":
		ensure  => present,
		content => template('mirebalais_reporting/restart-server.sh.erb'),
		owner   => root,
		group   => root,
		mode    => '0755'
	}

    # disable this job, set to "absent" for now
	cron { 'restart-server.sh':
		ensure  => absent,
		command => '/usr/local/sbin/restart-server.sh &>/dev/null 2>&1',
		user    => 'root',
		hour    => 06,
		minute  => 10,
		require => [ File['/usr/local/sbin/restart-server.sh'] ]
	}
}