###
# Puppet Script to build and install Guacamole Server on Ubuntu 24.04
###

$guacamole_server_source_folder = "/home/${default_user}/code/guacamole-server"

$build_dependencies = [
  'libcairo2-dev',

  # 'libjpeg62-dev',
  'libjpeg-turbo8-dev',
  'libjpeg-dev',
  'libjpeg8-dev',

  'libpng-dev',
  'uuid-dev',
  'libavcodec-dev',
  'libavformat-dev',
  'libavutil-dev',
  'libswscale-dev',
  'freerdp2-dev',
  'libpango1.0-dev',
  'libssh2-1-dev',
  'libtelnet-dev',
  'libvncserver-dev',
  'libwebsockets-dev',
  'libpulse-dev',
  'libssl-dev',
  'libvorbis-dev',
  'libwebp-dev',
]

package { $build_dependencies:
  ensure => 'installed',
}

# required for PDF printing to client from server
package { 'ghostscript':
  ensure => 'installed',
}

file { 'guacamole-drive':
  ensure  => directory,
  path    => '/guacamole-drive',
  replace => false,
  owner   => 'daemon',
  group   => 'daemon',
  mode    => '0770',
}

file { 'guacamole-server-source-folder':
  ensure  => directory,
  path    => $guacamole_server_source_folder,
  replace => false,
  owner   => $default_user,
  group   => $default_user,
  require => File['default_user_code_folder'],
}

vcsrepo { 'guacamole-server-source':
  ensure             => latest,
  path               => $guacamole_server_source_folder,
  provider           => git,
  source             => 'https://github.com/apache/guacamole-server.git',
  revision           => 'master',
  keep_local_changes => false,  # TODO(AR) change this to 'true' once https://github.com/puppetlabs/puppetlabs-vcsrepo/pull/623 is merged and released
  owner              => $default_user,
  group              => $default_user,
  require            => [
    Package['git'],
    File['guacamole-server-source-folder'],
  ],
}

exec { 'guacamole-server-autoreconf':
  cwd      => $guacamole_server_source_folder,
  command  => 'autoreconf -fi',
  path     => '/usr/bin',
  provider => shell,
  user     => $default_user,
  creates  => "${guacamole_server_source_folder}/configure",
  require  => [
    Package['gcc'],
    Package['g++'],
    Package['make'],
    Package['libtool-bin'],
    Package['autotools-dev'],
    Package['autoconf'],
    Vcsrepo['guacamole-server-source'],
    Package[$build_dependencies],
    Package['ghostscript'],
  ],
}

exec { 'guacamole-server-configure':
  cwd      => $guacamole_server_source_folder,
  command  => "${guacamole_server_source_folder}/configure --with-systemd-dir=/etc/systemd/system",
  path     => '/usr/bin',
  provider => shell,
  user     => $default_user,
  creates  => "${guacamole_server_source_folder}/Makefile",
  require  => [
    Exec['guacamole-server-autoreconf'],
  ],
}

exec { 'guacamole-server-make':
  cwd      => $guacamole_server_source_folder,
  command  => 'make -j4',
  path     => '/usr/bin',
  provider => shell,
  user     => $default_user,
  creates  => "${guacamole_server_source_folder}/src/guacd/guacd-daemon.o",
  require  => [
    Exec['guacamole-server-configure'],
  ],
}

exec { 'install-guacamole-server':
  cwd      => $guacamole_server_source_folder,
  command  => 'make install',
  path     => '/usr/bin',
  provider => shell,
  user     => 'root',
  creates  => '/usr/local/sbin/guacd',
  require  => [
    Exec['guacamole-server-make'],
  ],
}
~> exec { 'guacamole-server-ldconfig':
  cwd      => $guacamole_server_source_folder,
  command  => 'ldconfig',
  path     => '/usr/sbin',
  provider => shell,
  user     => 'root',
  require  => [
    Exec['install-guacamole-server'],
  ],
}

service { 'guacd':
  ensure  => running,
  enable  => true,
  require => [
    Exec['guacamole-server-ldconfig'],
    File['guacamole-drive'],
  ],
}
