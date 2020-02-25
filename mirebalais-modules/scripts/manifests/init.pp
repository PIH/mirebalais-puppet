class scripts (

$clean_disk_hour = hiera('clean_disk_hour'),

) {

file { "cleandiskspace":
   ensure => present,
   path    => '/usr/local/sbin/cleandiskspace.sh',
   mode    => '0700',
   owner   => 'root',
   group   => 'root',
   content => template('.erb'),
   require => File["/home/${tomcat}/backups"]
  }

cron { 'clean-disk-space':
   ensure  => present,
   command => '/usr/local/sbin/cleandiskspace.sh > /dev/null',
   user    => 'root',
   hour    => "${clean_disk_hour}",
   minute  => 00,
   environment => "MAILTO=${sysadmin_email}",
   require =>  File['cleandiskspace.sh']
  }