class mirebalais_reporting::reporting_setup (
	$openmrs_db = hiera('openmrs_db'),
	$openmrs_db_user = decrypt(hiera('openmrs_db_user')),
	$openmrs_db_password = decrypt(hiera('openmrs_db_password')),
	$openmrs_warehouse_db = decrypt(hiera('openmrs_warehouse_db')),
	$backup_db_password = decrypt(hiera('backup_db_password')),
	$sysadmin_email = hiera('sysadmin_email')
) {
	
	# note that public/private key sharing needs to be set up manually between production and reporting
	user {
		backups:
    		ensure => 'present',
    		home   => "/home/backups",
    		shell  => '/bin/sh',
  	}

  	file { "/home/reporting/percona":
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '0755',
        require =>  Package['percona-xtrabackup']
      }

      file { "/home/reporting/percona/scripts":
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '0755',
        require =>  File["/home/reporting/percona"]
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

	/*file { 'mirebalaiswarehousedbdump.sh':
		ensure  => present,
		path    => '/usr/local/sbin/mirebalaiswarehousedbdump.sh',
		mode    => '0700',
		owner   => 'root',
		group   => 'root',
		content => template('mirebalais_reporting/mirebalaiswarehousedbdump.sh.erb'),
	}*/


	cron { 'mirebalais-reporting-db-source':
		ensure  => absent,
		command => '/usr/local/sbin/mirebalaisreportingdbsource.sh >/dev/null 2>&1',
		user    => 'root',
		hour    => 18,
		minute  => 00,
		environment => 'MAILTO=${sysadmin_email}',
		require => [ File['mirebalaisreportingdbsource.sh'], Package['p7zip-full'] ]
	}


	file { 'mirebalais-backup-reporting-db-n-tables-tables.sh':
		ensure  => absent,
		path    => '/usr/local/sbin/mirebalais-backup-reporting-db-n-tables-tables.sh',
		mode    => '0700',
		owner   => 'root',
		group   => 'root',
		content => template('mirebalais_reporting/mirebalais-backup-reporting-db-n-tables-tables.sh.erb'),
	}

	cron { 'mirebalais-backup-reporting-db-n-tables-tables':
		ensure  => absent,
		command => '/usr/local/sbin/mirebalais-backup-reporting-db-n-tables-tables.sh >/dev/null 2>&1',
		user    => 'root',
		hour    => 20,
		minute  => 30,
		environment => 'MAILTO=${sysadmin_email}',
		require => [ File['mirebalais-backup-reporting-db-n-tables-tables.sh'] ]
	}

	file { 'mirebalais-percona-restore.sh':
		ensure  => present,
		path    => '/home/reporting/percona/scripts/mirebalais-percona-restore.sh',
		mode    => '0700',
		owner   => 'root',
		group   => 'root',
		content => template('mirebalais_reporting/mirebalais-percona-restore.sh.erb'),
	}

	cron { 'mirebalais-percona-restore':
		ensure  => present,
		command => '/home/reporting/percona/scripts/mirebalais-percona-restore.sh >/dev/null 2>&1',
		user    => 'root',
		hour    => 00,
		minute  => 30,
		environment => 'MAILTO=${sysadmin_email}',
		require => [ File['mirebalais-percona-restore.sh'] ]
	}
}
