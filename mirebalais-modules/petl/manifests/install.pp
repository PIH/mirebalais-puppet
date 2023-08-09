define petl::install (
  $petl                            = hiera("petl"),
  $petl_user                       = hiera("petl_user"),
  $petl_home_dir                   = hiera("petl_home_dir"),
  $petl_site                       = hiera('petl_site'),
  $petl_version                    = hiera("petl_version"),
  $petl_java_home                  = hiera("petl_java_home"),
  $petl_java_opts                  = hiera("petl_java_opts"),
  $petl_server_port                = hiera("petl_server_port"),
  $petl_config_dir                 = hiera("petl_config_dir"),
  $petl_mysql_host                 = hiera("petl_mysql_host"),
  $petl_mysql_port                 = hiera("petl_mysql_port"),
  $petl_mysql_databaseName         = hiera("petl_mysql_databaseName"),
  $petl_mysql_options              = hiera("petl_mysql_options"),
  $petl_mysql_user                 = decrypt(hiera("petl_mysql_user")),
  $petl_mysql_password             = decrypt(hiera("petl_mysql_password")),
  $petl_sqlserver_host             = decrypt(hiera("petl_sqlserver_host")),
  $petl_sqlserver_port             = decrypt(hiera("petl_sqlserver_port")),
  $petl_sqlserver_databaseName     = hiera("petl_sqlserver_databaseName"),
  $petl_sqlserver_user             = decrypt(hiera("petl_sqlserver_user")),
  $petl_sqlserver_password         = decrypt(hiera("petl_sqlserver_password")),
  $petl_config_name                = hiera('petl_config_name'),
  $petl_config_version             = hiera('petl_config_version'),
  $petl_cron_time                  = hiera('petl_cron_time'),
) {

    user { "${petl}":
        ensure => "present",
        home   => "${petl_home_dir}",
        shell  => "/bin/bash"
    }

    file { "${petl_home_dir}":
        ensure  => directory,
        owner   => "${petl}",
        group   => "${petl}",
        mode    => "0755",
        require => User["${petl}"]
    }

    file { "${petl_home_dir}/data":
        ensure  => directory,
        owner   => "${petl}",
        group   => "${petl}",
        mode    => "0755",
        require => File["${petl_home_dir}"]
    }

    file { "${petl_home_dir}/work":
        ensure  => directory,
        owner   => "${petl}",
        group   => "${petl}",
        mode    => "0755",
        require => File["${petl_home_dir}"]
    }

    file { "${petl_home_dir}/bin":
        ensure  => directory,
        owner   => "${petl}",
        group   => "${petl}",
        mode    => "0755",
        require => File["${petl_home_dir}"]
    }

    if ('SNAPSHOT' in $petl_version) {
        $petl_repo = "snapshots"
    }
    else {
        $petl_repo = "releases"
    }

    wget::fetch { "download-petl-jar for ${petl_site}":
        source      => "https://s01.oss.sonatype.org/service/local/artifact/maven/content?g=org.pih&a=petl&r=${petl_repo}&p=jar&v=${petl_version}",
        destination => "${petl_home_dir}/bin/${petl}-${petl_version}.jar",
        timeout     => 0,
        verbose     => false,
        redownload  => ('SNAPSHOT' in $petl_version),
        require     => File["${petl_home_dir}/bin"]
    }

    file { "${petl_home_dir}/bin/${petl}-${petl_version}.jar":
        ensure  => present,
        owner   => "${petl}",
        group   => "${petl}",
        mode    => "0755",
        require => Wget::Fetch["download-petl-jar for ${petl_site}"]
    }

    file { "${petl_home_dir}/bin/${petl}.jar":
        ensure  => link,
        target  => "${petl_home_dir}/bin/${petl}-${petl_version}.jar",
        require => File["${petl_home_dir}/bin/${petl}-${petl_version}.jar"],
    }

    file { "${petl_home_dir}/bin/petl.conf":
        ensure  => present,
        content => template("petl/petl.conf.erb"),
        owner   => "${petl}",
        group   => "${petl}",
        mode    => "0755",
        require => File["${petl_home_dir}/bin/${petl}.jar"]
    }

    file { "${petl_home_dir}/bin/application.yml":
        ensure  => present,
        content => template("petl/application-${petl_site}.yml.erb"),
        owner   => "${petl}",
        group   => "${petl}",
        mode    => "0755",
        require => File["${petl_home_dir}/bin/${petl}.jar"],
    }

    # remove any old versions of PETL
        exec { "rm -f $(find ${petl_home_dir}/bin -maxdepth 1 -type f -name 'petl-*.jar' ! -name '${petl}-$petl_version.jar')":
        require => File["${petl_home_dir}/bin/${petl}-${petl_version}.jar"]
    }

    # Ensure PETL service installed, but stopped

    file { "/etc/init.d/${petl}":
      ensure  => 'link',
      target  => "${petl_home_dir}/bin/${petl}-${petl_version}.jar",
      require => [ File["${petl_home_dir}/bin/petl.conf"], File["${petl_home_dir}/bin/${petl}-${petl_version}.jar"] ]
    }

    service { "${petl}":
      ensure  => stopped,
      require => File["/etc/init.d/${petl}"],
    }

    if ('SNAPSHOT' in $petl_config_version) {
        $petl_config_repo = "snapshots"
    }
    else {
        $petl_config_repo = "releases"
    }

    wget::fetch { "download-petl-config-dir for ${petl_site}":
        source      => "https://s01.oss.sonatype.org/service/local/artifact/maven/content?g=org.pih.openmrs&a=${petl_config_name}&r=${petl_config_repo}&c=distribution&p=zip&v=${petl_config_version}",
        destination => "/tmp/petl-${petl_config_name}.zip",
        timeout     => 0,
        verbose     => false,
        redownload  => true,
    }

    exec { "install-petl-config-dir for ${petl_site}":
      command => "rm -rf /tmp/${petl_site}* && rm -rf /tmp/${petl_site}_configuration && unzip -o /tmp/petl-${petl_config_name}.zip -d /tmp/${petl_site}_configuration && rm -rf ${petl_home_dir}/${petl_config_dir} && mkdir -p ${petl_home_dir}/${petl_config_dir} && cp -r /tmp/${petl_site}_configuration/* ${petl_home_dir}/${petl_config_dir} && chown -R ${petl}:${petl} ${petl_home_dir}",
      require => [ Wget::Fetch["download-petl-config-dir for ${petl_site}"], Package['unzip'], Service["${petl}"]],
    }

    file { "/etc/logrotate.d/petl-${petl_site}":
        ensure  => file,
        content => template("petl/logrotate-${petl}.erb")
    }

    # Setup PETL to startup at boot and restart now

    exec { 'remove ${petl} automatic startup files':
        command => "rm -rf /etc/rc0.d/K01${petl} && rm -rf /etc/rc1.d/K01${petl} && rm -rf /etc/rc2.d/S03${petl} && rm -rf /etc/rc3.d/S03${petl} && rm -rf /etc/rc4.d/S03${petl} && rm -rf /etc/rc5.d/S03${petl} && rm -rf /etc/rc6.d/K01${petl}",
        require => File["/etc/init.d/${petl}"]
    }

    exec { "${petl}-startup-enable":
      command => "/usr/sbin/update-rc.d -f ${petl} defaults 81",
      user    => 'root',
      require => File["/etc/init.d/${petl}"]
    }

    exec { "${petl}-service-start":
      command => "service ${petl} start",
      user    => 'root',
      require => File["/etc/init.d/${petl}"],
    }

}
