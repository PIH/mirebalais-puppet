
# Put documentation in place
class cesemr_user_resources() {

  exec { 'cesemr_user_resources':
    command     => "/bin/bash -c 'cd /tmp; rm -rf ces-laptop-resources; git clone https://github.com/PIH/ces-laptop-resources.git; cd ces-laptop-resources; cp -r CES\ EMR\ Recursos /home/doc/Escritorio/; chown doc:doc -R CES\ EMR\ Recursos'",
    user        => 'root'
  }

}
