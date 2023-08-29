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
  $sysadmin_email = hiera('sysadmin_email'),
  $acme_dns_username = decrypt(hiera('acme_dns_username')),
  $acme_dns_password = decrypt(hiera('acme_dns_password')),
  $acme_dns_subdomain = decrypt(hiera('acme_dns_subdomain')),
  $acme_dns_base_url = decrypt(hiera('acme_dns_base_url')),
  $cert_cron_hour = hiera('cert_cron_hour'),
  $cert_cron_min = hiera('cert_cron_min'),
  $apache_cron_restart_hour = hiera('apache_cron_restart_hour'),
  $apache_cron_restart_min = hiera('apache_cron_restart_min'),
){

  include base_packages

  # really ugly way to do string concat, ignoring empties
  $worker_list = join(split("${webapp_name} ${pwa_webapp_name} ${biometrics_webapp_name}", '\s+'), ',')

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
  ensure => absent,
  purge => true,
  force => true,
  }

  file { '/var/www/html/index.html':
  ensure => absent,
  purge => true,
  force => true,
  }

  exec { 'enable and disable apache mods':
    command     => 'a2enmod jk && a2enmod deflate && a2enmod ssl && a2ensite default-ssl && a2enmod rewrite',
    user        => 'root',
    subscribe   => [ Package['apache2'], Package['libapache2-mod-jk'] ],
    refreshonly => true,
    notify      => Service['apache2']
  }

  file { "/var/acme":
    ensure => directory,
    owner   => "root",
    group   => "root"
  }

  # clear out old non-ecc certs, can likely be removed after we upgrade to acme dns
  file { "/var/acme/.acme.sh/$site_domain" :
    ensure => absent,
    recurse => true,
    force   => true,
  }

  file { "/etc/letsencrypt" :
    ensure => directory,
    owner   => "root",
    group   => "root"
  }

  file { "/etc/letsencrypt/live" :
    ensure => directory,
    owner   => "root",
    group   => "root",
    require => File["/etc/letsencrypt"]
  }

  file { "/etc/letsencrypt/live/$site_domain" :
    ensure => directory,
    owner   => "root",
    group   => "root",
    mode    => '0710',
    require => File["/etc/letsencrypt/live"]
  }

  file { "install-letsencrypt.sh":
    ensure  => present,
    path    => "/var/acme/install-letsencrypt.sh",
    mode    => '0700',
    owner   => "root",
    group   => "root",
    content => template('apache2/install-letsencrypt.sh.erb'),
    require => File["/var/acme"],
    notify => Exec['run install letsencrypt'],
  }

  exec { "download acme from the git repo":
    command => "rm -rf /var/acme/acme.sh && git clone https://github.com/acmesh-official/acme.sh.git /var/acme/acme.sh",
    require => File["/var/acme"]
  }

  # note refresh-only, this onle runs when the let encrypt script changes
  exec { "run install letsencrypt":
    command => "/var/acme/install-letsencrypt.sh",
    require =>  [ Exec['download acme from the git repo'], File["/var/acme/.acme.sh/$site_domain"] ],
    refreshonly => true,
  }

  cron { "renew certificates using acme user":
    ensure  => present,
    command => "'/var/acme/.acme.sh'/acme.sh --cron --home '/var/acme/.acme.sh' > /dev/null",
    user    => "root",
    hour    => "$cert_cron_hour",
    minute  => "$cert_cron_min",
    environment => "MAILTO=$sysadmin_email",
    require => File["/var/acme"]
  }

  cron { "restart apache2":
    ensure  => present,
    command => "/usr/sbin/service apache2 restart > /dev/null",
    user    => root,
    hour    => "$apache_cron_restart_hour",
    minute  => "$apache_cron_restart_min",
    environment => "MAILTO=$sysadmin_email",
    require => Cron["renew certificates using acme user"]
  }

  file { '/etc/apache2/sites-available/default-ssl.conf':
    ensure => file,
    content => template('apache2/default-ssl.conf.erb'),
    require => [Package['apache2'], Exec['download acme from the git repo'] , Exec['run install letsencrypt']],
    notify => Service['apache2']
  }

  # ensure symlink created between sites enabled and sites available (should happen automatically but I blew this away in one case)
  file { '/etc/apache2/sites-enabled/default-ssl.conf':
    ensure  => link,
    target  => '../sites-available/default-ssl.conf',
    require => [Package['apache2'], Exec['download acme from the git repo'], Exec['install letsencrypt']]
  }

  # remove old certbot cron job
  # TODO: we *do* want to remove this job, but doing so via Puppet is causing issues (possibly because it has been manually commented out?)
/*  cron { "renew certificates":
    ensure  => absent,
  }*/

  # allows other modules to trigger an apache restart
  # there's an annoying tight dependency here we should fix
 /* exec { 'apache-restart':
    command     => "service apache2 restart",
    user        => 'root',
    refreshonly => true,
    subscribe => [ File["orderentry.zip"], File["labworkflow.zip"] ]
  }
*/
}
