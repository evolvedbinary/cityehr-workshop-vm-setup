###
# Puppet Script for DBeaver on Ubuntu 24.04
###

include apt

apt::source { 'dbeaver':
  location => 'https://dbeaver.io/debs/dbeaver-ce',
  release  => '',
  repos    => '/',
  comment  => 'DBeaver',
  key      => {
    id     => '98F5A7CC1ABE72AC3852A007D33A1BD725ED047D',
    name   => 'dbeaver.gpg.key',
    source => 'https://dbeaver.io/debs/dbeaver.gpg.key',
  },
}

package { 'dbeaver-ce':
  ensure  => installed,
  require => [
    Package['desktop'],
    Package['temurin-17-jdk'],
    Apt::Source['dbeaver'],
  ],
}

file { 'dbeaver-ce-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/dbeaver-ce.desktop",
  source  => '/usr/share/applications/dbeaver-ce.desktop',
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    Package['dbeaver-ce'],
  ],
}

exec { 'gvfs-trust-dbeaver-ce-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/dbeaver-ce.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/dbeaver-ce.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['dbeaver-ce-desktop-shortcut'],
}

ini_setting { 'dbeaver-ce-desktop-shortcut-position':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'dbeaver-ce.desktop',
  setting => 'pos',
  value   => '@Point(266 12)',
  require => File['dbeaver-ce-desktop-shortcut'],
}
