class mysql_setup (
  $root_password                      = decrypt(hiera('mysql_root_password')),
  $mysql_bind_address                 = decrypt(hiera('mysql_bind_address')),
  $mysql_expire_logs_days             = hiera('mysql_expire_logs_days'),
  $mysql_innodb_buffer_pool_size      = hiera('mysql_innodb_buffer_pool_size'),
  $mysql_innodb_buffer_pool_instances = hiera('mysql_innodb_buffer_pool_instances'),
  $mysql_binary_logging               = hiera('mysql_binary_logging'),
  $mysql_server_id                    = hiera('mysql_server_id'),
  $mysql_net_read_timeout             = hiera('mysql_net_read_timeout'),
  $mysql_net_write_timeout            = hiera('mysql_net_write_timeout'),
  $mysql_wait_timeout                 = hiera('mysql_wait_timeout'),
  $mysql_interactive_timeout          = hiera('mysql_interactive_timeout'),
  $mysql_key_buffer_size              = hiera('mysql_key_buffer_size'),
  $mysql_table_open_cache             = hiera('mysql_table_open_cache'),
  $mysql_sort_buffer_size             = hiera('mysql_sort_buffer_size'),
  $timezone                           = hiera('server_timezone'),

){

  user { 'mysql':
    ensure => 'present',
    shell  => '/bin/sh',
  }

  # put proper /etc/mysql directory my.cnf in place
  file { '/etc/mysql':
    ensure  => directory
  }

  file { '/etc/mysql/my.cnf':
    ensure  => file,
    force => true,
    content => template('mysql_setup/my.cnf.erb'),
    require => File['/etc/mysql'],
    notify  => Service['mysqld']
  }

  # for some reason on a fresh install of Ubuntu 16.04, my.cnf is just a symlink to /etc/alternatives/my.cnf
  # which is in turn a sym link to /etc/mysql/my.cnf.fallback; so we just set this now as well
  # one we update fully to Ubuntu 16.04 and mysql, we should look into reworking this
  # see: https://askubuntu.com/questions/763774/mysql-istallation-problem-on-ubuntu-16-04-my-cnf-public-ip-problem
   file { '/etc/mysql/my.cnf.fallback':
    ensure  => present,
    force => true,
    content => template('mysql_setup/my.cnf.erb'),
    require => File['/etc/mysql'],
    notify  => Service['mysqld']
  }

  # also, due to an Ubuntu 16.04 mysql install bug we need to tell apparmor to allow mysql to access my.cnf.fallback
  file { "/etc/apparmor.d/local/usr.sbin.mysqld":
    ensure  => present,
    source  => "puppet:///modules/mysql_setup/usr.sbin.mysqld"
  }

  # make sure the mysql 5,5 is uninstalled, as well as the custom "mysql" package we put in place
  # note that we put the proper my.cnf in place first because any restarting of mysql requires this package to be present
  package { 'mysql-client-5.5':
    ensure  => purged,
    require => File['/etc/mysql/my.cnf']
  }
  package { 'mysql-client-core-5.5':
    ensure  => purged,
    require => Package['mysql-client-5.5']
  }
  package { 'mysql-server-5.5':
    ensure  => purged,
    require => Package['mysql-client-core-5.5']
  }
  package { 'mysql-server-core-5.5':
    ensure  => purged,
    require => Package['mysql-server-5.5']
  }
  package { 'mysql':
    ensure  => purged,
    require => Package['mysql-server-core-5.5']
  }

  # make sure old files are removed
  file {'/opt/mysql':
    ensure => absent,
    recurse => true,
    purge => true,
    force => true,
    require => Package['mysql']
  }

  file { '/etc/init.d/mysql.server':
    ensure  => absent,
    require => Package['mysql']
  }

  # make sure old mysql apt source we set up on bamboo is absent
  apt::source { 'mysql':
    ensure      => absent,
    require => Package['mysql']
  }

  # set root password automatically
  exec {
    'set-root-password':
      command => "/bin/echo mysql-server mysql-server/root_password password $root_password | /usr/bin/debconf-set-selections",
      user => root
  }

  exec {
    'confirm-root-password':
      command => "/bin/echo mysql-server mysql-server/root_password_again password $root_password | /usr/bin/debconf-set-selections",
      user => root,
      require => Exec['set-root-password']
  }


  # install mysql 5.6
  package { 'mysql-server-5.6':
    ensure  => installed,
    require => [Exec['set-root-password'], Exec['confirm-root-password'], Package['mysql'],
      File['/opt/mysql'], File['/etc/init.d/mysql.server'], File['/etc/mysql/my.cnf']]
  }

  package { 'mysql-client-5.6':
    ensure  => installed,
    require => [Package['mysql-server-5.6'], Exec['set-root-password'], Exec['confirm-root-password']]
  }

  file { "root_user_my.cnf":
    path        => "${root_home}/.my.cnf",
    content     => template('mysql_setup/my.cnf.pass.erb'),
    require     => Exec['confirm-root-password'],
  }

  service { 'mysqld':
    ensure  => running,
    name    => 'mysql',
    enable  => true,
    require => [ File['/etc/mysql/my.cnf'], File['/etc/mysql/my.cnf.fallback'], File['root_user_my.cnf'], Package['mysql-server-5.6'] ],
  }

  ## these next blocks configures the timezone in mysql
  exec { 'configure-timezone':
    command => "/usr/bin/mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -uroot -p${root_password} mysql",
    user => root,
    require => [Exec['set-root-password'], Exec['confirm-root-password'], Package['mysql-client-5.6'], Service[mysqld]]
  }

  # this is only added once and only if the variable doesn't exist
  exec { 'add-timezone-if-not-exist':
    command => "/bin/bash -c \"if ! grep -q 'default-time-zone=${timezone}' /etc/mysql/my.cnf; then sed -i '/^#timezone/a default-time-zone=${timezone}' /etc/mysql/my.cnf; fi\"",
    require => [ File['/etc/mysql/my.cnf'], Service[mysqld], Exec['configure-timezone']],
  }

  # restart mysql
  exec { 'mysql-restart':
    command     => "service mysql restart",
    user        => 'root',
    require     =>  [Service[mysqld], Exec['configure-timezone'], Exec['add-timezone-if-not-exist']]
  }
  
}