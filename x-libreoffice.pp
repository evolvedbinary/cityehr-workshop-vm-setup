###
# Puppet Script for LibreOffice on Ubuntu 24.04
###

package { 'libreoffice':
  ensure  => installed,
  require => Package['desktop'],
}

file { 'libreoffice-writer-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/libreoffice-writer.desktop",
  source  => '/usr/share/applications/libreoffice-writer.desktop',
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    Package['libreoffice'],
  ],
}

exec { 'gvfs-trust-libreoffice-writer-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/libreoffice-writer.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/libreoffice-writer.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['libreoffice-writer-desktop-shortcut'],
}

file { 'libreoffice-calc-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/libreoffice-calc.desktop",
  source  => '/usr/share/applications/libreoffice-calc.desktop',
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    Package['libreoffice'],
  ],
}

exec { 'gvfs-trust-libreoffice-calc-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/libreoffice-calc.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/libreoffice-calc.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['libreoffice-calc-desktop-shortcut'],
}

ini_setting { 'libreoffice-writer-desktop-shortcut-position':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'libreoffice-writer.desktop',
  setting => 'pos',
  value   => '@Point(139 264)',
  require => File['libreoffice-writer-desktop-shortcut'],
}

ini_setting { 'libreoffice-calc-desktop-shortcut-position':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'libreoffice-calc.desktop',
  setting => 'pos',
  value   => '@Point(139 390)',
  require => File['libreoffice-calc-desktop-shortcut'],
}
