class petl (
  $petl                        = split(hiera("petl"), ','),
  $petl_home_dir               = split(hiera("petl_home_dir"), ','),
  $petl_site                   = split(hiera('petl_site'), ','),
  $petl_version                = hiera("petl_version"),
  $petl_java_home              = hiera("petl_java_home"),
  $petl_java_opts              = hiera("petl_java_opts"),
  $petl_server_port            = hiera("petl_server_port"),
  $petl_config_dir             = hiera("petl_config_dir"),
  $petl_mysql_host             = hiera("petl_mysql_host"),
  $petl_mysql_port             = hiera("petl_mysql_port"),
  $petl_mysql_databaseName     = hiera("petl_mysql_databaseName"),
  $petl_mysql_options          = hiera("petl_mysql_options"),
  $petl_mysql_user             = decrypt(hiera("petl_mysql_user")),
  $petl_mysql_password         = decrypt(hiera("petl_mysql_password")),
  $petl_sqlserver_host             = hiera("petl_sqlserver_host"),
  $petl_sqlserver_port             = hiera("petl_sqlserver_port"),
  $prod_dw_petl_sqlserver_host     = decrypt(hiera("prod_dw_petl_sqlserver_host")),
  $prod_dw_petl_sqlserver_port     = decrypt(hiera("prod_dw_petl_sqlserver_port")),
  $petl_sqlserver_databaseName     = split(hiera("petl_sqlserver_databaseName"), ','),
  $petl_sqlserver_user             = decrypt(hiera("petl_sqlserver_user")),
  $petl_sqlserver_password         = decrypt(hiera("petl_sqlserver_password")),
  $petl_check_errors_cron_hour     = hiera("petl_check_errors_cron_hour"),
  $petl_error_subject              = hiera("petl_error_subject"),
  $petl_config_name                = split(hiera('petl_config_name'), ','),
  $petl_config_version             = split(hiera('petl_config_version'), ','),
  $petl_cron_time                  = hiera('petl_cron_time'),
  $petl_ces_cron_time              = hiera('petl_ces_cron_time'),
  $sysadmin_email                  = hiera("sysadmin_email"),
  $repo_url                        = decrypt(hiera('repo_url')),
) {

  # iterate within the petl list, note this number increases if the element increase
  # usage [0,1] supports 2 elements, for 3 elements use [0,1,2]
  $array_list = [0, 1]

  each($array_list) |$index| {
    ## if the value is true, then its an empty string do nothing
    ## This is for supporting yaml files with array lists and those without array
    unless empty($petl_site[$index]) == true {

      # Setup User, and Home Directory for PETL installation
      user { "${petl[$index]}":
        ensure => "present",
        home   => "${petl_home_dir[$index]}",
        shell  => "/bin/bash"
      }

      file { "${petl_home_dir[$index]}":
        ensure  => directory,
        owner   => "${petl[$index]}",
        group   => "${petl[$index]}",
        mode    => "0755",
        require => User["${petl[$index]}"]
      }

      # Setup work and data directories

      file { "${petl_home_dir[$index]}/data":
        ensure  => directory,
        owner   => "${petl[$index]}",
        group   => "${petl[$index]}",
        mode    => "0755",
        require => File["${petl_home_dir[$index]}"]
      }

      file { "${petl_home_dir[$index]}/work":
        ensure  => directory,
        owner   => "${petl[$index]}",
        group   => "${petl[$index]}",
        mode    => "0755",
        require => File["${petl_home_dir[$index]}"]
      }

      # Setup application binaries

      file { "${petl_home_dir[$index]}/bin":
        ensure  => directory,
        owner   => "${petl[$index]}",
        group   => "${petl[$index]}",
        mode    => "0755",
        require => File["${petl_home_dir[$index]}"]
      }

      if ('SNAPSHOT' in $petl_version) {
        $petl_repo = "snapshots"
      }
      else {
        $petl_repo = "releases"
      }

      wget::fetch { "download-petl-jar for ${petl_site[$index]}":
        source      => "https://s01.oss.sonatype.org/service/local/artifact/maven/content?g=org.pih&a=petl&r=${petl_repo}&p=jar&v=${petl_version}",
        destination => "${petl_home_dir[$index]}/bin/${petl[$index]}-${petl_version}.jar",
        timeout     => 0,
        verbose     => false,
        redownload  => ('SNAPSHOT' in $petl_version),
      }

      file { "${petl_home_dir[$index]}/bin/${petl[$index]}-${petl_version}.jar":
        ensure  => present,
        owner   => "${petl[$index]}",
        group   => "${petl[$index]}",
        mode    => "0755",
        require => Wget::Fetch["download-petl-jar for ${petl_site[$index]}"]
      }


      file { "${petl_home_dir[$index]}/bin/${petl[$index]}.jar":
        ensure  => link,
        target  => "${petl_home_dir[$index]}/bin/${petl[$index]}-${petl_version}.jar",
        require => File["${petl_home_dir[$index]}/bin/${petl[$index]}-${petl_version}.jar"],
      }

      file { "${petl_home_dir[$index]}/bin/petl.conf":
        ensure  => present,
        content => template("petl/petl.conf.erb"),
        owner   => "${petl[$index]}",
        group   => "${petl[$index]}",
        mode    => "0755",
        require => File["${petl_home_dir[$index]}/bin/${petl[$index]}.jar"]
      }

      file { "${petl_home_dir[$index]}/bin/application.yml":
        ensure  => present,
        content => template("petl/application-${petl_site[$index]}.yml.erb"),
        owner   => "${petl[$index]}",
        group   => "${petl[$index]}",
        mode    => "0755",
        require => File["${petl_home_dir[$index]}/bin/${petl[$index]}.jar"],
      }

      # remove any old versions of PETL
      exec { "rm -f $(find $petl_home_dir/bin -maxdepth 1 -type f -name 'petl-*.jar' ! -name '${petl_version}.jar')":
        require => File["${petl_home_dir[$index]}/bin/${petl[$index]}-${petl_version}.jar"]
      }

      if ('SNAPSHOT' in $petl_config_version[$index]) {
        $petl_config_repo = "snapshots"
      }
      else {
        $petl_config_repo = "releases"
      }

      wget::fetch { "download-petl-config-dir for ${petl_site[$index]}":
        source      => "https://s01.oss.sonatype.org/service/local/artifact/maven/content?g=org.pih.openmrs&a=${petl_config_name[$index]}&r=${petl_config_repo}&c=distribution&p=zip&v=${petl_config_version[$index]}",
        destination => "/tmp/petl-${petl_config_name[$index]}.zip",
        timeout     => 0,
        verbose     => false,
        redownload  => true,
      }

      # Set up scripts and services to execute PETL

      # TODO: This requires openjdk-8-jdk to be installed
      if ('petl-ces' == $petl[$index]) {

        file { "/etc/init.d/petl-ces":
          ensure  => 'link',
          target  => "${petl_home_dir[$index]}/bin/${petl[$index]}-${petl_version}.jar",
          require => [ File["${petl_home_dir[$index]}/bin/petl.conf"], File["${petl_home_dir[$index]}/bin/${petl[$index]}-${petl_version}.jar"] ]
        }

        # this is a hacky way of ensuring that petl-ces starts up since update-rc.d throw error for multiple instances.
        # note this is only need for servers that can 2 instances of petl
        # upon server restart, service petl-ces start/restart/stop should work
        exec { "petl-startup-enable for petl-ces":
          command => "/usr/bin/ln -s /etc/init.d/petl-ces /etc/rc0.d/K01petl-ces && /usr/bin/ln -s /etc/init.d/petl-ces /etc/rc1.d/K01petl-ces && /usr/bin/ln -s /etc/init.d/petl-ces /etc/rc2.d/S03petl-ces && /usr/bin/ln -s /etc/init.d/petl-ces /etc/rc3.d/S03petl-ces && /usr/bin/ln -s /etc/init.d/petl-ces /etc/rc4.d/S03petl-ces && /usr/bin/ln -s /etc/init.d/petl-ces /etc/rc5.d/S03petl-ces && /usr/bin/ln -s /etc/init.d/petl-ces /etc/rc6.d/K01petl-ces",
          user    => 'root',
          group   => 'root',
          unless  => "/bin/ls -ap /etc/rc*.d | grep petl-ces | grep -v grep",
          require => File["/etc/init.d/petl-ces"]
        }

        # make sure PETL is installed, but stopped... we will start it after we install the config
        # there is a conflict when this is a service.
        exec { "stop-petl-ces":
          command  => "/etc/init.d/petl-ces stop",
          require => Exec["petl-startup-enable for petl-ces"]
        }

        exec { "install-petl-config-dir for ${petl_site[$index]}":
          command => "rm -rf /tmp/${petl_site[$index]}* && rm -rf /tmp/${petl_site[$index]}_configuration && unzip -o /tmp/petl-${petl_config_name[$index]}.zip -d /tmp/${petl_site[$index]}_configuration && rm -rf ${petl_home_dir[$index]}/${petl_config_dir} && mkdir -p ${petl_home_dir[$index]}/${petl_config_dir} && cp -r /tmp/${petl_site[$index]}_configuration/* ${petl_home_dir[$index]}/${petl_config_dir} && chown -R ${petl[$index]}:${petl[$index]} ${petl_home_dir[$index]}",
          require => [ Wget::Fetch["download-petl-config-dir for ${petl_site[$index]}"], Package['unzip'], Exec["stop-petl-ces"]],
        }

        # just restart PETL every time the deploy runs
        exec { "petl-restart for site petl-ces":
          command => "/etc/init.d/petl-ces start",
          user    => 'root',
          require => File["/etc/init.d/petl-ces"]
        }
      }

      if ('petl-ces' != $petl[$index]) {
        file { "/etc/init.d/petl":
          ensure  => 'link',
          target  => "${petl_home_dir[$index]}/bin/${petl[$index]}-${petl_version}.jar",
          require => [ File["${petl_home_dir[$index]}/bin/petl.conf"], File["${petl_home_dir[$index]}/bin/${petl[$index]}-${petl_version}.jar"] ]
        }

        exec { "petl-startup-enable":
          command => "/usr/sbin/update-rc.d -f petl defaults 81",
          user    => 'root',
          require => File["/etc/init.d/petl"]
        }

        # make sure PETL is installed, but stopped... we will start it after we install the config
        service { "petl":
          ensure  => stopped,
          enable  => true,
          require => Exec["petl-startup-enable"]
        }

        exec { "install-petl-config-dir for ${petl_site[$index]}":
          command => "rm -rf /tmp/${petl_site[$index]}* && rm -rf /tmp/${petl_site[$index]}_configuration && unzip -o /tmp/petl-${petl_config_name[$index]}.zip -d /tmp/${petl_site[$index]}_configuration && rm -rf ${petl_home_dir[$index]}/${petl_config_dir} && mkdir -p ${petl_home_dir[$index]}/${petl_config_dir} && cp -r /tmp/${petl_site[$index]}_configuration/* ${petl_home_dir[$index]}/${petl_config_dir} && chown -R ${petl[$index]}:${petl[$index]} ${petl_home_dir[$index]}",
          require => [ Wget::Fetch["download-petl-config-dir for ${petl_site[$index]}"], Package['unzip'], Service["petl"]],
        }

        # just restart PETL every time the deploy runs
        exec { "petl-restart for petl":
          command => "service petl start",
          user    => 'root',
          require => Service["petl"],
        }
      }

      ## logrotate
      file { "/etc/logrotate.d/petl-${petl_site[$index]}":
        ensure  => file,
        content => template("petl/logrotate-${petl[$index]}.erb")
      }

      /* Now that we have petl execution tables, this may be unrequired.
      will just keep them in for now, maybe we will expand on these lines or remove them at a
      later point
      # Petl error file
      file { "/usr/local/sbin/petl-${petl_site[$index]}-checkErrors.sh":
        ensure  => present,
        content => template('petl/checkPetlErrors.sh.erb'),
        owner   => root,
        group   => root,
        mode    => '0755',
        require => File["${petl_home_dir[$index]}/bin"]
      }

      cron { "petl-error for $index":
        ensure  => present,
        command => "/usr/local/sbin/petl-${petl_site[$index]}-checkErrors.sh &> /dev/null",
        user    => 'root',
        hour    => "${petl_check_errors_cron_hour}",
        minute  => 00,
        require => File["/usr/local/sbin/petl-${petl_site[$index]}-checkErrors.sh"]
      } */
    }
  }
}
