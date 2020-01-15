class openmrs::spa (
  $tomcat = hiera('tomcat')
) {

  include nodejs

  package { 'git':
    ensure => installed,
  }

  vcsrepo { "/home/${tomcat}/.OpenMRS/frontend-build":
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/pih/spa-frontend.git',
    revision => 'master',
    require => [Service[$tomcat],Package['git']]
  }

  exec{'build_and_link_spa':
    command => "npm install && npm run build && ln -sf $(realpath openmrs/frontend /home/${tomcat}/.OpenMRS/frontend)",
    cwd => "/home/${tomcat}/.OpenMRS/frontend-build",
    require => Vcsrepo["/home/${tomcat}/.OpenMRS/frontend-build"]
  }

}
