class percona::setup_cron_to_refresh_report_dbs (
    $percona_restore_dir               = decrypt(hiera('percona_restore_dir')),
    $reporting_system                  = hiera('petl_site')
  ) {

    require percona::install_restore_scripts

    if ($reporting_system != '') {
        file { "${percona_restore_dir}/refresh-report-dbs-${reporting_system}.sh":
          ensure  => file,
          content => template("percona/refresh-report-dbs-${reporting_system}.sh.erb"),
          mode    => '0700',
          owner   => 'root',
          group   => 'root',
          require     => File["${percona_restore_dir}"]
        }
        cron { 'restore-and-deidentify-report-dbs':
          ensure      => present,
          command     => "${percona_restore_dir}/refresh-report-dbs-${reporting_system}.sh",
          environment => "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin",
          user        => 'root',
          hour        => 20,
          minute      => 45,
          require     => File["${percona_restore_dir}/percona-restore-and-email.sh"]
        }
    }
}
