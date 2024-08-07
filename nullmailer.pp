###
# Puppet Script for nullmailer on Ubuntu 24.04
###
$smtp_relay_host = 'jess.evolvedbinary.com'

file { '/etc/nullmailer':
  ensure => directory,
  owner  => 'root',
  group  => 'root',
  mode   => '0755',
}

file { '/etc/mailname':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => $networking[fqdn],
}

file { '/etc/nullmailer/me':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => $networking[hostname],
  require => File['/etc/nullmailer'],
}

file { '/etc/nullmailer/defaultdomain':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => $networking[domain],
  require => File['/etc/nullmailer'],
}

file { '/etc/nullmailer/remotes':
  ensure  => file,
  owner   => 'mail',
  group   => 'mail',
  mode    => '0640',
  content => "${smtp_relay_host} smtp",
  require => File['/etc/nullmailer'],
}

package { 'nullmailer':
  ensure  => installed,
  require => [
    File['/etc/mailname'],
    File['/etc/nullmailer/me'],
    File['/etc/nullmailer/defaultdomain'],
    File['/etc/nullmailer/remotes'],
  ],
}

service { 'nullmailer':
  ensure  => running,
  require => Package['nullmailer'],
}
