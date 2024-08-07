###
# Puppet Script for an RDP Server on Ubuntu 24.04
###

include ufw

package { 'xrdp':
  ensure => installed,
}

service { 'xrdp':
  ensure  => running,
  enable  => true,
  require => Package['xrdp'],
}

ufw::allow { 'xrdp':
  port    => '3389',
  require => Service['xrdp'],
}
