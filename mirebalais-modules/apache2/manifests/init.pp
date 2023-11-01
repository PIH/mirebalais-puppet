class apache2 (
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
  $sysadmin_email = decrypt(hiera('sysadmin_email')),
  $acme_version = hiera('acme_version'),
  $acme_user = decrypt(hiera('acme_user')),
  $acme_dns_username = decrypt(hiera('acme_dns_username')),
  $acme_dns_password = decrypt(hiera('acme_dns_password')),
  $acme_dns_subdomain = decrypt(hiera('acme_dns_subdomain')),
  $acme_dns_base_url = decrypt(hiera('acme_dns_base_url')),
  $cert_cron_hour = hiera('cert_cron_hour'),
  $cert_cron_min = hiera('cert_cron_min'),
  $apache_cron_restart_hour = hiera('apache_cron_restart_hour'),
  $apache_cron_restart_min = hiera('apache_cron_restart_min'),
  $tomcat_ajp_secret = decrypt(hiera('tomcat_ajp_secret'))
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

  # create user for acme.sh
  user { "$acme_user":
    ensure     => 'present',
    home       => "/var/$acme_user/",
    shell      => '/usr/sbin/nologin',
    managehome => false,

  }

  # create home directory for acme.sh user
  file { "/var/$acme_user":
    ensure => directory,
    owner   => "$acme_user",
    group   => "$acme_user",
    require => User["$acme_user"]
    }

  # edit sudoers file to allow the acme user to reload (not restart) apache2
  file_line { "$acme_user sudo":
    path  => '/etc/sudoers',
    line  => "$acme_user ALL=(ALL) NOPASSWD: /bin/systemctl reload apache2.service",
    match => "^$acme_user",
    require => User["$acme_user"]
  }

  # clear out old non-ecc certs, can likely be removed after we upgrade to acme dns
  file { "/var/$acme_user/.acme.sh/$site_domain" :
    ensure => absent,
    recurse => true,
    force   => true,
    require => File["/var/$acme_user"]
  }

  # create all the directories where we install the acme scripts
  file { "/etc/letsencrypt" :
    ensure => directory,
    owner   => "$acme_user",
    group   => "$acme_user",
    recurse => true,
  }

  file { "/etc/letsencrypt/live" :
    ensure => directory,
    owner   => "$acme_user",
    group   => "$acme_user",
    recurse => true,
    require => File["/etc/letsencrypt"]
  }

  file { "/etc/letsencrypt/live/$site_domain" :
    ensure => directory,
    owner   => "$acme_user",
    group   => "$acme_user",
    mode    => '0710',
    recurse => true,
    require => File["/etc/letsencrypt/live"]
  }

  # install install-certs.sh
  file { "install-certs.sh":
    ensure  => present,
    path    => "/var/$acme_user/install-certs.sh",
    mode    => '0700',
    owner   => "$acme_user",
    group   => "$acme_user",
    content => template('apache2/install-certs.sh.erb'),
    require => File["/var/$acme_user"],
    notify => [ Exec['run install certs'], Exec['install acme.sh tool'] ],
  }

  # install acme
  # note: refresh-only, so this only runs when the install cert script changes (see notify above)
  exec { "install acme.sh tool":
    command => "sudo -H -u acme bash -c 'wget -O -  https://raw.githubusercontent.com/acmesh-official/acme.sh/$acme_version/acme.sh | sh -s -- --install-online -m  emrsysadmin@pih.org --home /var/acme'",
    cwd => "/var/$acme_user",
    require => [ File["/var/$acme_user"], File["/var/$acme_user/acme.sh"], User["$acme_user"] ],
    refreshonly => true,
  }
  # run script to install the scripts
  # note refresh-only, this only runs when the install-cert script changes (see notify on install-cert.sh)
  exec { "run install certs":
    command => "sudo -H -u acme bash -c /var/$acme_user/install-certs.sh",
    cwd => "/var/$acme_user",
    require =>  [ Exec['install acme.sh tool'], File["/var/$acme_user/.acme.sh/$site_domain"] ],
    refreshonly => true,
  }

  # CLEANUP: remove old git clone install of acme
  file { "/var/$acme_user/acme.sh" :
    ensure => absent,
    recurse => true,
    force   => true
  }

  # CLEANUP: remove old install-letscript script (renaming to install-certs.sh)
  file { "install-letsencrypt.sh":
    ensure  => absent,
    path    => "/var/$acme_user/install-letsencrypt.sh"
  }

  # CLEANUP: remove any cron installed on root
  cron { "renew certificates using acme user":
    ensure  => absent,
    user    => 'root'
  }

  # CLEANUP: remove manually set up cron (we will now rely on the one set up by the acme.sh install)
  cron { "cron renew certificates using acme user":
    ensure  => absent,
    user    => "$acme_user",
    require => User["$acme_user"]
  }

  cron { "restart apache2":
    ensure  => present,
    command => "/usr/sbin/service apache2 restart > /dev/null",
    user    => root,
    hour    => "$apache_cron_restart_hour",
    minute  => "$apache_cron_restart_min",
    environment => "MAILTO=$sysadmin_email",
  }

  file { '/etc/apache2/sites-available/default-ssl.conf':
    ensure => file,
    content => template('apache2/default-ssl.conf.erb'),
    require => [Package['apache2'], Exec['run install certs']],
    notify => Service['apache2']
  }

  # ensure symlink created between sites enabled and sites available (should happen automatically but I blew this away in one case)
  file { '/etc/apache2/sites-enabled/default-ssl.conf':
    ensure  => link,
    target  => '../sites-available/default-ssl.conf',
    require => [Package['apache2'],  Exec['run install certs']]
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
