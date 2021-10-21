class petl (
  $petl                        = hiera("petl"),
  $petl_version                = hiera("petl_version"),
  $petl_java_home              = hiera("petl_java_home"),
  $petl_java_opts              = hiera("petl_java_opts"),
  $petl_server_port            = hiera("petl_server_port"),
  $petl_job_dir                = hiera("petl_job_dir"),
  $petl_schedule_cron          = hiera("petl_schedule_cron"),
  $petl_datasource_dir         = hiera("petl_datasource_dir"),
  $petl_database_url           = hiera("petl_database_url"),
  $petl_mysql_host             = hiera("petl_mysql_host"),
  $petl_mysql_port             = hiera("petl_mysql_port"),
  $petl_mysql_databaseName     = hiera("petl_mysql_databaseName"),
  $petl_mysql_options          = hiera("petl_mysql_options"),
  $petl_mysql_user             = decrypt(hiera("petl_mysql_user")),
  $petl_mysql_password         = decrypt(hiera("petl_mysql_password")),
  $petl_sqlserver_host             = hiera("petl_sqlserver_host"),
  $petl_sqlserver_port             = hiera("petl_sqlserver_port"),
  $petl_sqlserver_databaseName     = hiera("petl_sqlserver_databaseName"),
  $petl_sqlserver_user             = hiera("petl_sqlserver_user"),
  $petl_sqlserver_password         = decrypt(hiera("petl_sqlserver_password")),
  $petl_check_errors_cron_hour     = hiera("petl_check_errors_cron_hour"),
  $petl_error_subject              = hiera("petl_error_subject"),
  $sysadmin_email                  = hiera("sysadmin_email"),

) {

  # Setup User, and Home Directory for PETL installation

  user { "$petl":
    ensure  => "present",
    home    => "/home/$petl",
    shell   => "/bin/bash"
  }

  file { "/home/$petl":
    ensure  => directory,
    owner   => "$petl",
    group   => "$petl",
    mode    => "0755",
    require => User["$petl"]
  }

  # Setup work and data directories

  file { "/home/$petl/data":
    ensure  => directory,
    owner   => "$petl",
    group   => "$petl",
    mode    => "0755",
    require => File["/home/$petl"]
  }

  file { "/home/$petl/work":
    ensure  => directory,
    owner   => "$petl",
    group   => "$petl",
    mode    => "0755",
    require => File["/home/$petl"]
  }

  # Setup application binaries

  file { "/home/$petl/bin":
    ensure  => directory,
    owner   => "$petl",
    group   => "$petl",
    mode    => "0755",
    require => File["/home/$petl"]
  }

  wget::fetch { "download-petl-jar":
    source      => "http://bamboo.pih-emr.org/artifacts/petl-$petl_version.jar",
    destination => "/home/$petl/bin/petl-$petl_version.jar",
    timeout     => 0,
    verbose     => false,
    require => File["/home/$petl/bin"]
  }

  file { "/home/$petl/bin/petl-$petl_version.jar":
    ensure  => present,
    owner   => $petl,
    group   => $petl,
    mode    => "0755",
    require => Wget::Fetch['download-petl-jar']
  }

  file { "/home/$petl/bin/petl.jar":
    ensure  => link,
    target => "/home/$petl/bin/petl-$petl_version.jar",
    require => File["/home/$petl/bin/petl-$petl_version.jar"],
    notify => Exec['petl-restart']
  }

  # remove any old versions of PETL
  exec { "rm -f $(find . -maxdepth 1 -type f -name 'petl-*.jar' ! -name 'petl-$petl_version.jar')":
    require => File["/home/$petl/bin/petl.jar"]
  }

  file { "/home/$petl/bin/petl.conf":
    ensure  => present,
    content => template("petl/petl.conf.erb"),
    owner   => $petl,
    group   => $petl,
    mode    => "0755",
    require => File["/home/$petl/bin/petl.jar"]
  }

  file { "/home/$petl/bin/application.yml":
    ensure  => present,
    content => template("petl/application.yml.erb"),
    owner   => $petl,
    group   => $petl,
    mode    => "0755",
    require => File["/home/$petl/bin/petl.jar"],
    notify => Exec['petl-restart']
  }

  # Set up scripts and services to execute PETL

  # TODO: This requires openjdk-8-jdk to be installed

  file { "/etc/init.d/$petl" :
    ensure => 'link',
    target => "/home/$petl/bin/petl.jar",
    require => [ File["/home/$petl/bin/petl.conf"], File["/home/$petl/bin/petl.jar"] ]
  }

  exec { 'petl-startup-enable':
    command     => "/usr/sbin/update-rc.d -f $petl defaults 81",
    user        => 'root',
    require => File["/etc/init.d/$petl"]
  }

  service { $petl:
    ensure  => running,
    enable  => true,
    require => Exec["petl-startup-enable"]
  }

  # just restart PETL every time the deploy runs
  exec { 'petl-restart':
    command     => "service $petl restart",
    user        => 'root',
    require => Service["$petl"],
  }

  ## logrotate
  file { '/etc/logrotate.d/petl':
    ensure  => file,
    content  => template('petl/logrotate.erb')
  }

  # Petl error file
  file { "/usr/local/sbin/checkPetlErrors.sh":
    ensure  => present,
    content => template('petl/checkPetlErrors.sh.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
    require => File["/home/$petl/bin"]
  }

  cron { 'petl-error':
    ensure  => present,
    command => '/usr/local/sbin/checkPetlErrors.sh &> /dev/null',
    user    => 'root',
    hour    => "${petl_check_errors_cron_hour}",
    minute  => 00,
    require => File["/usr/local/sbin/checkPetlErrors.sh"]
  }

}
