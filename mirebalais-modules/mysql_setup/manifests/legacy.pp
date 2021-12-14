# legacy puppet script used to install mysql on all Mirebalais servers
# we should be using the new, main "init.pp" everywhere now



class mysql_setup::legacy (
  $root_password                    = decrypt(hiera('mysql_root_password')),
  $mysql_bind_address               = hiera('mysql_bind_address'),
  $mysql_expire_logs_days           = hiera('mysql_expire_logs_days'),
  $mysql_innodb_buffer_pool_size    = hiera('mysql_innodb_buffer_pool_size'),
  $repo_url                         = decrypt(hiera('repo_url')),
) {

  apt::source { 'mysql':
    ensure      => present,
    location    => "${repo_url}/mysql-repo",
    release     => 'stable/',
    repos       => '',
    include_src => false,
  }

  package { 'libaio1':
    ensure  => latest,
    require => [ Apt::Source['mysql'] ],
  }

  package { 'mysql':
    ensure  => latest,
    require => [ Package['libaio1'] ],
  }

  user { 'mysql':
    ensure => 'present',
    shell  => '/bin/sh',
  }

  file { '/opt/mysql/server-5.6/':
    ensure  => present,
    owner   => mysql,
    group   => mysql,
    recurse => inf,
    require => [ Package['mysql'], User['mysql'] ],
  }

  file { "/etc/mysql":
    ensure  => directory,
    owner   => mysql,
    group   => mysql,
    mode    => '0755',
    require => User['mysql'],
  }

  file { "/etc/mysql/conf.d":
    ensure  => directory,
    owner   => mysql,
    group   => mysql,
    mode    => '0755',
    require => File['/etc/mysql'],
  }

  file { '/etc/mysql/my.cnf':
    ensure  => file,
    content => template('mysql_setup/my.cnf.legacy.erb'),
    require => [ File['/etc/mysql'] ],
  }

  file { '/usr/bin/mysqladmin':
    ensure => link,
    target => '/opt/mysql/server-5.6/bin/mysqladmin',
    require => Package['mysql'],
  }

  exec { 'set_mysql_rootpassword':
    command     => "mysqladmin -u root password '${root_password}'",
    logoutput   => true,
    environment => "HOME=${root_home}",
    unless      => "mysqladmin -u root -p'${root_password}' status > /dev/null",
    path        => '/usr/local/sbin:/usr/bin:/usr/local/bin',
    require     => Service['mysqld'],
  }

  file { "root_user_my.cnf":
    path        => "${root_home}/.my.cnf",
    content     => template('mysql_setup/my.cnf.pass.erb'),
    require     => Exec['set_mysql_rootpassword'],
  }

  exec { 'install_db':
    creates   => '/etc/init.d/mysql.server',  # this just means that this not execute if this mysql.server file has been created (i.e., prevents this from being run twice)
    command   => "mysql_install_db --user=mysql --datadir=/var/lib/mysql",
    path      => ["/opt/mysql/server-5.6/scripts", "/opt/mysql/server-5.6/bin"],
    require   => [ Package['mysql'], User['mysql'] ],
  }

  file { '/usr/bin/mysql':
    ensure => link,
    target => '/opt/mysql/server-5.6/bin/mysql',
    require => [ Package['mysql'] ],
  }

  file { '/etc/init.d/mysql.server':
    ensure  => present,
    source  => '/opt/mysql/server-5.6/support-files/mysql.server',
    mode    => '0755',
    owner   => 'mysql',
    group   => 'mysql',
    require => [ Exec['install_db'] ],
  }

# make sure the old upstart startup file for mysql 5.5 is not present
  file { '/etc/init/mysql.conf':
    ensure => absent
  }

  service { 'mysqld':
    ensure  => running,
    name    => 'mysql.server',
    enable  => true,
    require => [ Exec['install_db'], File['/etc/init.d/mysql.server/'], File['/opt/mysql/server-5.6/'], File['/etc/mysql/conf.d'], File['/etc/mysql/my.cnf']  ],
  }

}
