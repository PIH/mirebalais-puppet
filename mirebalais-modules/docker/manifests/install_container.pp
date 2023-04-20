class docker::install_container (

  $docker_container_dir = hiera('docker_container_dir'),
  $docker_mssql_container_name = hiera('docker_mssql_container_name'),
  $docker_mssql_image = hiera('docker_mssql_image'),
  $docker_mssql_sa_password = hiera('docker_mssql_sa_password'),
  $docker_mssql_user_password = hiera('docker_mssql_user_password'),
  $docker_mssql_volume_dir = hiera('docker_mssql_volume_dir'),
  $docker_mysql_container_name = hiera('docker_mysql_container_name'),
  $docker_mysql_image = hiera('docker_mysql_image'),
  $docker_mysql_volume_dir = hiera('docker_mysql_volume_dir'),
  $docker_mysql_sa_password = hiera('docker_mysql_sa_password'),
  $docker_mysql_user_password = hiera('docker_mysql_user_password'),
  $docker_group = hiera('docker_group'),
  $docker_user = hiera('docker_user'),

  $server_timezone = hiera('server_timezone')
)
  {
    file { '${docker_container_dir}':
      ensure => directory,
      owner   => $docker_user,
      group   => $docker_group,
      mode    => '0644'
    }

    if ($docker_mysql_image != "") {
      file { '${docker_container_dir}/mysql':
        ensure  => directory,
        owner   => $docker_user,
        group   => $docker_group,
        mode    => '0644',
        require => File['${docker_container_dir}']
      }
    }

    if ($docker_mssql_image != "") {
      file { '${docker_container_dir}/mssql':
        ensure    => directory,
        owner   => $docker_user,
        group   => $docker_group,
        mode    => '0644',
        require => File['${docker_container_dir}']
    }
      file { '${docker_container_dir}/mssql/data':
        ensure    => directory,
        owner   => $docker_user,
        group   => $docker_group,
        mode    => '0644',
        require => [File['${docker_container_dir}'], File['${docker_container_dir}/mssql']]
      }
  }

  file { '${docker_container_dir}/docker-compose.yml':
    ensure  => present,
    content => template('docker/docker-compose.yml.erb'),
    owner   => $docker_user,
    group   => $docker_group,
    mode    => '0644',
    require => File['${docker_container_dir}']
  }
  }

