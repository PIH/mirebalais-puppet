# we should change the name of this class
# maybe base_packages?
class unzip() {

  package { 'unzip':
    ensure => installed,
  }

  package { 'p7zip-full' :
    ensure => installed
  }

}
