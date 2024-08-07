###
# Puppet Script for a C++ Environment on Ubuntu 24.04
###

package { 'gcc':
  ensure => installed,
}

package { 'g++':
  ensure  => installed,
  require => Package['gcc'],
}

package { 'make':
  ensure  => installed,
}

package { 'libtool-bin':
  ensure => installed,
}

package { 'autotools-dev':
  ensure => installed,
}

package { 'autoconf':
  ensure => installed,
}
