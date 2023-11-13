class percona::setup_cron_to_refresh_openmrs_db (
    $percona_restore_dir               = decrypt(hiera('percona_restore_dir')),
    $percona_restore_deidentify        = hiera('percona_restore_deidentify'),
    $percona_restore_preserve_tables   = hiera('percona_restore_preserve_tables').
    $site_name                         = ''
  ) {

    require percona::install_restore_scripts

    if ($site_name != '') {
        cron { 'restore-and-deidentify-openmrs-db':
          ensure      => present,
          command     => "${percona_restore_dir}/percona-restore-and-email.sh --siteToRestore=${site_name} --deidentify=${percona_restore_deidentify} --preserveTables="${percona_restore_preserve_tables}" --restartOpenmrs=true",
          environment => "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin",
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
