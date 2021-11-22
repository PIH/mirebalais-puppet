class docker (
  $docker_repo = hiera('docker_repo'),
  $docker_compose_version = hiera('docker_compose_version')
) {

  exec { "apt_update":
    command    => "/usr/bin/apt -y update"
  }

  exec { "apt_upgrade":
    command    => "/usr/bin/apt -y upgrade"
  }

  exec { "apt_dist_upgrade":
    command    => "/usr/bin/apt -y dist-upgrade"
  }

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

  exec { "docker_key":
    command      => "/usr/bin/curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
    require => Package['curl']
  }

  exec { "docker_repo":
    command      => "/usr/bin/add-apt-repository '$docker_repo'",
    require       => Exec['docker_key']
  }

  package { 'docker-ce':
    ensure => installed,
    notify => [ Exec['apt_update'], Exec['apt_upgrade'], Exec['apt_dist_upgrade'] ],
    require => [ Package['apt-transport-https'], Package['curl'], Package['software-properties-common'], Package['ca-certificates'], Exec['docker_repo'] ]
  }

  ##### docker-compose
  exec { "delete_docker_compose_repo":
    command      => 'rm -rf /usr/local/bin/docker-compose',
  }

  exec { "docker_compose_repo":
    command      => "curl -L 'https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-Linux-x86_64' -o /usr/local/bin/docker-compose",
    require => Exec[delete_docker_compose_repo]
  }

  exec { "install_docker_compose":
    command      => 'chmod +x /usr/local/bin/docker-compose',
    require       => [Exec[delete_docker_compose_repo], Exec['docker_compose_repo']]
  }

}