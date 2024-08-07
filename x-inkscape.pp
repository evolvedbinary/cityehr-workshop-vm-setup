###
# Puppet Script for Inkscape on Ubuntu 24.04
###

package { 'inkscape':
  ensure  => installed,
  require => Package['desktop'],
}

file { 'inkscape-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/inkscape.desktop",
  source  => '/usr/share/applications/org.inkscape.Inkscape.desktop',
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    Package['inkscape'],
  ],
}

exec { 'gvfs-trust-inkscape-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/inkscape.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/inkscape.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['inkscape-desktop-shortcut'],
}

ini_setting { 'inkscape-desktop-shortcut-position':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'inkscape.desktop',
  setting => 'pos',
  value   => '@Point(139 516)',
  require => File['inkscape-desktop-shortcut'],
}
