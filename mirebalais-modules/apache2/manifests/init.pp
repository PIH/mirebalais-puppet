class apache2 (
  $tomcat = hiera('tomcat'),
  $services_ensure = hiera('services_ensure'),
  $services_enable = hiera('services_enable'),
  $site_domain = hiera('site_domain'),
  $webapp_name = hiera('webapp_name'),
  $ssl_cert_file = hiera('ssl_cert_file'),
  $ssl_chain_file = hiera('ssl_chain_file'),
  $ssl_key_file = hiera('ssl_key_file'),
  $ssl_cert_dir = hiera('ssl_cert_dir'),
  $ssl_key_dir = hiera('ssl_key_dir'),
  $ssl_use_letsencrypt = hiera('ssl_use_letsencrypt'),
  $biometrics_enabled = hiera('biometrics_enabled'),
  $biometrics_webapp_name = hiera('biometrics_webapp_name'),
  $biometrics_port = hiera('biometrics_port'),
  $pwa_enabled = hiera('pwa_enabled'),
  $pwa_webapp_name = hiera('pwa_webapp_name'),
  $keyserver = hiera('keyserver'),
  $letsencrypt_user = decrypt(hiera('letsencrypt_user')),
  $letsencrypt_user_password = decrypt(hiera('letsencrypt_user_password')),
  $sysadmin_email = hiera('sysadmin_email'),
  $azure_dns_subscription_id = decrypt(hiera('azure_dns_subscription_id')),
  $azure_dns_tenant_id = decrypt(hiera('azure_dns_tenant_id')),
  $azure_dns_app_id = decrypt(hiera('azure_dns_app_id')),
  $azure_dns_client_secret = decrypt(hiera('azure_dns_client_secret')),
){

  # really ugly way to do string concat, ignoring empties
  $worker_list = join(split("${webapp_name} ${pwa_webapp_name} ${biometrics_webapp_name}", '\s+'), ',')

  package { 'software-properties-common':
    ensure => present
  }

  package { 'apache2':
    ensure => installed,
  }

  package { 'libapache2-mod-jk':
    ensure => installed,
  }

  service { 'apache2':
    ensure   => $services_ensure,
    enable   => $services_enable,
    require  => [ Package['apache2'], Package['libapache2-mod-jk'] ],
  }

  file { '/etc/logrotate.d/apache2':
    ensure  => file,
    content  => template('apache2/logrotate.erb')
  }

  file { '/etc/apache2/workers.properties':
    ensure  => present,
    content => template('apache2/workers.properties.erb'),
    notify  => Service['apache2']
  }

  file { '/etc/apache2/ports.conf':
    ensure => present,
    source => 'puppet:///modules/apache2/ports.conf',
    notify => Service['apache2']
  }

  file { '/etc/apache2/mods-available/jk.conf':
    ensure => present,
    source => 'puppet:///modules/apache2/jk.conf',
    notify => Service['apache2']
  }

  file { '/etc/apache2/sites-available/default':
    ensure => absent
  }

  file { '/etc/apache2/sites-available/000-default.conf':
    ensure => file,
    source => 'puppet:///modules/apache2/sites-available/000-default.conf',
    notify => Service['apache2']
  }

  file { '/var/www/html/.htaccess':
    ensure => file,
    source => 'puppet:///modules/apache2/www/htaccess'
  }

  file { '/var/www/html/index.html':
    ensure => file,
    content => template('apache2/index.html.erb')
  }

  exec { 'enable and disable apache mods':
    command     => 'a2enmod jk && a2enmod deflate && a2enmod ssl && a2ensite default-ssl && a2enmod rewrite',
    user        => 'root',
    subscribe   => [ Package['apache2'], Package['libapache2-mod-jk'] ],
    refreshonly => true,
    notify      => Service['apache2']
  }

  user { "$letsencrypt_user":
    ensure => 'present',
    password => "$letsencrypt_user_password",
    home => "/var/$letsencrypt_user",
    managehome => true,
    shell => '/bin/bash'
  }

  file { "/etc/letsencrypt" :
    ensure => directory,
    owner   => "$letsencrypt_user",
    group   => "root",
    require => User["$letsencrypt_user"]
  }

  file { "/etc/letsencrypt/live" :
    ensure => directory,
    owner   => "$letsencrypt_user",
    group   => "root",
    require => File["/etc/letsencrypt"]
  }

  file { "/etc/letsencrypt/live/$site_domain" :
    ensure => directory,
    owner   => "$letsencrypt_user",
    group   => "root",
    mode    => '0710',
    require => File["/etc/letsencrypt/live"]
  }

  file { "install-letsencrypt.sh":
    ensure  => present,
    path    => "/var/$letsencrypt_user/install-letsencrypt.sh",
    mode    => '0700',
    owner   => "$letsencrypt_user",
    group   => root,
    content => template('apache2/install-letsencrypt.sh.erb'),
    require => User["$letsencrypt_user"]
  }

  exec { "add user to sudoers":
    unless  => "/bin/cat /etc/sudoers | grep $letsencrypt_user",
    command => "echo '$letsencrypt_user    ALL=(ALL) NOPASSWD: /usr/sbin/service apache2 restart' | sudo EDITOR='tee -a' visudo",
    require => User["$letsencrypt_user"]
  }

  exec { "download and from the git repo":
    command => "rm -rf /var/$letsencrypt_user/acme.sh && git clone https://github.com/acmesh-official/acme.sh.git /var/$letsencrypt_user/acme.sh",
    require => User["$letsencrypt_user"]
  }

  # the unless condition only allow this script to run once.
  exec { "download and run install letsencrypt using $letsencrypt_user":
    unless  => "/bin/ls -ap /var/$letsencrypt_user | grep '^\..*/$' | grep acme.sh | grep -v grep",
    command => "/var/$letsencrypt_user/install-letsencrypt.sh",
    require => [User["$letsencrypt_user"], Exec['download and from the git repo']]
  }

  cron { "renew certificates using $letsencrypt_user user":
    ensure  => present,
    command => "'/var/$letsencrypt_user/.$letsencrypt_user.sh'/$letsencrypt_user.sh --cron --home '/var/$letsencrypt_user/.$letsencrypt_user.sh' > /dev/null",
    user    => "$letsencrypt_user",
    hour    => 23,
    minute  => 00,
    environment => "MAILTO=${sysadmin_email}",
    require => User["$letsencrypt_user"]
  }

  cron { "restart apache2 $letsencrypt_user user":
    ensure  => present,
    command => "sudo service apache2 restart > /dev/null",
    user    => root,
    hour    => 23,
    minute  => 03,
    environment => "MAILTO=${sysadmin_email}",
    require => Cron["renew certificates using $letsencrypt_user user"]
  }

  file { '/etc/apache2/sites-available/default-ssl.conf':
    ensure => file,
    content => template('apache2/default-ssl.conf.erb'),
    require => [Package['apache2'], User["$letsencrypt_user"], Exec['download and from the git repo'], Exec["download and run install letsencrypt using $letsencrypt_user"]],
    notify => Service['apache2']
  }

  # ensure symlink created between sites enabled and sites available (should happen automatically but I blew this away in one case)
  file { '/etc/apache2/sites-enabled/default-ssl.conf':
    ensure  => link,
    target  => '../sites-available/default-ssl.conf',
    require => [Package['apache2'], User["$letsencrypt_user"], Exec['download and from the git repo'], Exec["download and run install letsencrypt using $letsencrypt_user"]]
  }

  # allows other modules to trigger an apache restart
  # there's an annoying tight dependency here we should fix
  exec { 'apache-restart':
    command     => "service apache2 restart",
    user        => 'root',
    refreshonly => true,
    subscribe => [ File["orderentry.zip"], File["labworkflow.zip"] ]
  }

}