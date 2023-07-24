class percona::setup_cron_to_refresh_openmrs_db (
    $percona_restore_dir               = decrypt(hiera('percona_restore_dir')),
    $site_name                         = ''
  ) {

    require percona::install_restore_scripts

    if ($site_name != '') {
        cron { 'restore-and-deidentify-openmrs-db':
          ensure      => present,
          command     => "${percona_restore_dir}/percona-restore-and-email.sh --siteToRestore=${site_name} --deidentify=true --restartOpenmrs=true",
          user        => 'root',
          hour        => 19,
          minute      => 50,
          require     => File["${percona_restore_dir}/percona-restore-and-email.sh"]
        }
        file { "/etc/logrotate.d/percona-restore":
          ensure  => file,
          content => template("percona/logrotate-percona-restore.erb")
        }
    }
}
