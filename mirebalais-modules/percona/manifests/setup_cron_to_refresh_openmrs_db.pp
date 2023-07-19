class percona::setup_cron_to_refresh_openmrs_db (
    $percona_restore_dir               = decrypt(hiera('percona_restore_dir')),
    $site_name                         = ''
  ) {

    require percona::restore_setup

    if ($site_name != '') {
        file { '${percona_restore_dir}/restore-and-deidentify-openmrs-db.sh':
            ensure => present,
            source => 'puppet:///modules/percona/restore-and-deidentify-openmrs-db.sh'
        }
        cron { 'restore-and-deidentify-openmrs-db':
          ensure      => present,
          command     => '${percona_restore_dir}/restore-and-deidentify-openmrs-db.sh ${site_name}',
          user        => 'root',
          hour        => 19,
          minute      => 50,
          require     => File["${percona_restore_dir}/restore-and-deidentify-openmrs-db.sh"]
        }
    }
}
