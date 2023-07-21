class percona::setup_cron_to_refresh_openmrs_db (
    $percona_restore_dir               = decrypt(hiera('percona_restore_dir')),
    $site_name                         = ''
  ) {

    require percona::install_restore_scripts

    if ($site_name != '') {
        file { '${percona_restore_dir}/restore-and-deidentify-openmrs-db.sh':
          ensure => present,
          source => 'puppet:///modules/percona/restore-and-deidentify-openmrs-db.sh',
          path    => "${percona_restore_dir}/restore-and-deidentify-openmrs-db.sh",
          mode    => '0700',
          owner   => 'root',
          group   => 'root',
        }
        cron { 'restore-and-deidentify-openmrs-db':
          ensure      => present,
          command     => "${percona_restore_dir}/restore-and-deidentify-openmrs-db.sh ${site_name}",
          user        => 'root',
          hour        => 19,
          minute      => 50,
          require     => File["${percona_restore_dir}/restore-and-deidentify-openmrs-db.sh"]
        }
        file { "/etc/logrotate.d/percona-restore-${site_name}":
          ensure  => file,
          content => template("percona/logrotate-percona-restore.erb")
        }
    }
}
