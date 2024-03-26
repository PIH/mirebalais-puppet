class commcare_sync(
  $commcare_sync_app_name = "commcare_sync",
  $container_dir = "/container",
  $commcare_sync_app_dir = "${container_dir}/${commcare_sync_app_name}",
  $dockerdata_dir = "/dockerdata",
  $commcare_sync_data_dir = "${$dockerdata_dir}/${commcare_sync_app_name}",
  $commcare_sync_postgres_data_dir = "${commcare_sync_data_dir}/postgres",
  $commcare_sync_media_dir = "${commcare_sync_data_dir}/media",
  $commcare_sync_redis_data_dir = "${commcare_sync_data_dir}/redis",
  $commcare_sync_admin_password = decrypt(hiera('commcare_sync_admin_password')),
  $commcare_sync_postgres_password = decrypt(hiera('commcare_sync_postgres_password')),
  $commcare_sync_secret_key = decrypt(hiera('commcare_sync_secret_key')),
  $sysadmin_email = decrypt(hiera('sysadmin_email')),
) {

    file { "${container_dir}":
        ensure  => directory,
        mode    => "0755",
    }

    file { "${commcare_sync_app_dir}":
        ensure  => directory,
        mode    => "0755",
        require => File["${container_dir}"]
    }

    file { "${dockerdata_dir}":
        ensure  => directory,
        mode    => "0755",
        require => File["${commcare_sync_app_dir}"]
    }

    file { "${commcare_sync_data_dir}":
        ensure  => directory,
        mode    => "0755",
        require => File["${dockerdata_dir}"]
    }

    file { "${commcare_sync_postgres_data_dir}":
        ensure  => directory,
        mode    => "0600",
        require => File["${commcare_sync_data_dir}"]
    }

    file { "${commcare_sync_media_dir}":
        ensure  => directory,
        mode    => "0600",
        require => File["${commcare_sync_data_dir}"]
    }

    file { "${commcare_sync_redis_data_dir}":
        ensure  => directory,
        mode    => "0600",
        require => File["${commcare_sync_data_dir}"]
    }

    file { "${commcare_sync_app_dir}/localsettings.py":
        ensure  => present,
        path    => "${commcare_sync_app_dir}/localsettings.py",
        mode    => "0700",
        content => template('commcare_sync/localsettings.py.erb'),
        require => File["${commcare_sync_app_dir}"]
    }

    file { "${commcare_sync_app_dir}/docker-compose.yml":
        ensure  => present,
        path    => "${commcare_sync_app_dir}/docker-compose.yml",
        mode    => "0700",
        content => template('commcare_sync/docker-compose.yml.erb'),
        require => File["${commcare_sync_app_dir}/localsettings.py"]
    }

    file { "${commcare_sync_app_dir}/setup.sh":
      ensure => present,
      path    => "${commcare_sync_app_dir}/setup.sh",
      mode    => "0700",
      content => template('commcare_sync/setup.sh.erb'),
      require => File["${commcare_sync_app_dir}/docker-compose.yml"]
    }

    exec { "${commcare_sync_app_dir}/setup.sh":
        command => "bash setup.sh",
        cwd   => "${commcare_sync_app_dir}",
        require => File["${commcare_sync_app_dir}/setup.sh"]
    }
}
