# Install nodejs
class nodejs() {

  package { 'curl':
    ensure => installed,
  }

  exec { 'download node installer':
    command => 'curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -',
    require => Package['curl']
  }

  package { 'nodejs':
    ensure => installed,
    require => Exec['download node installer']
  }

}
