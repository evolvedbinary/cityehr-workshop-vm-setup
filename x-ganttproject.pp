###
# Puppet Script for GanttProject on Ubuntu 22.04
###

exec { 'download-ganttproject-deb':
  command => '/usr/bin/curl -L https://www.ganttproject.biz/dl/3.3.3309/lin -o /tmp/ganttproject.deb',
  unless  => '/usr/bin/dpkg -s ganttproject',
  require => Package['curl'],
}

package { 'ganttproject':
  ensure  => installed,
  source  => '/tmp/ganttproject.deb',
  require => [
    Package['desktop'],
    Package['temurin-17-jdk'],
    Exec['download-ganttproject-deb'],
  ],
}

# Add Desktop shortcut
file { 'ganttproject-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/ganttproject.desktop",
  source  => '/usr/share/applications/ganttproject.desktop',
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    Package['ganttproject'],
  ],
}

exec { 'gvfs-trust-ganttproject-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/ganttproject.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/ganttproject.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['ganttproject-shortcut'],
}

ini_setting { 'ganttproject-shortcut-position':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'ganttproject.desktop',
  setting => 'pos',
  value   => '@Point(266 516)',
  require => File['ganttproject-shortcut'],
}
