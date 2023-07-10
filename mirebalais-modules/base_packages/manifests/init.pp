class base_packages (
) {

  package { 'apt-transport-https':
    ensure => installed,
  }

  package { 'ca-certificates':
    ensure => installed,
  }

  package { 'curl':
    ensure => installed,
  }

  package { 'software-properties-common':
    ensure => installed,
  }

}