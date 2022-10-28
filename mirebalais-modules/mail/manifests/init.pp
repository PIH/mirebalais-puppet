class mail (
	$smtp_username = decrypt(hiera('smtp_username')),
	$smtp_userpassword = decrypt(hiera('smtp_userpassword')),
	$smtp_mailhub = decrypt(hiera('smtp_mailhub')),
	$site_domain = hiera('site_domain')
){

	package { 'sendmail':
		ensure => absent,
	}

	package { 'ssmtp':
		ensure => installed,
	}

	package { 'mailutils':
		ensure => installed,
		require => [ Package['ssmtp'] ]
	}

	file { "/etc/ssmtp":
		ensure  => directory,
		owner   => root,
		group   => mail,
		mode    => '0750',
		require =>  Package['ssmtp']
	}

	file { '/etc/ssmtp/ssmtp.conf':
		ensure  => file,
		group   => mail,
		mode    => '0640',
		content => template('mail/ssmtp.conf.erb'),
		require => [Package['ssmtp'], File['/etc/ssmtp']]
	}

}
