class maintenance (
    $sysadmin_email = decrypt(hiera('sysadmin_email')),
    $maintenance_reclaim_disk_space_hour = hiera('maintenance_reclaim_disk_space_hour')
  ) {

    class { 'apt::unattended_upgrades' :
              origins 	          => ['${distro_id} ${distro_codename}-security'],
              blacklist           => ['pihemr','mirebalais','tzdata'],
              update              => '1',
              download            => '1',
              upgrade             => '1',
              autoclean           => '1',
              mail_to	          => $sysadmin_email,
              auto_fix            => true,
              minimal_steps       => false,
              install_on_shutdown => false,
              auto_reboot         => false
     }

    file { "/root/reclaim-disk-space.sh":
      ensure  => present,
      source => 'puppet:///modules/maintenance/reclaim-disk-space.sh',
      path    => "/root/reclaim-disk-space.sh",
      owner   => root,
      group   => root,
      mode    => '0755',
    }

    if ($maintenance_reclaim_disk_space_hour != '') {
        cron { 'reclaim-disk-space':
          ensure      => present,
          command     => "/root/reclaim-disk-space.sh 2>&1 | /usr/bin/logger -t RECLAIM_DISK_SPACE",
          environment => "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin",
          user        => 'root',
          hour        => $maintenance_reclaim_disk_space_hour,
          minute      => 00,
          require     => File["/root/reclaim-disk-space.sh"]
        }
    }
}
