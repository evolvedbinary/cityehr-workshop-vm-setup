###
# Puppet Script for a Desktop Developer Environment using LXQT on Ubuntu 24.04
###

$desktop_background_image = "/home/${default_user}/Pictures/cityehrwork-desktop-background.png"

file { 'disable-screensaver':
  ensure  => file,
  path    => "/home/${default_user}/.xscreensaver",
  replace => false,
  mode    => '0664',
  content => 'mode:    off',
}

file_line { 'disable-screensaver':
  ensure  => present,
  path    => "/home/${default_user}/.xscreensaver",
  line    => 'mode:    off',
  match   => '^mode:',
  require => File['disable-screensaver'],
}

package { 'desktop':
  ensure  => installed,
  name    => 'lubuntu-desktop',
  require => File_line['disable-screensaver'],
}

# Workaround for https://bugs.launchpad.net/ubuntu/+source/lubuntu-default-settings/+bug/1708200
file { 'xterm':
  ensure  => link,
  path    => '/usr/bin/xterm',
  target  => '/usr/bin/qterminal',
  require => Package['desktop'],
}

file { 'default_user_desktop_folder':
  ensure  => directory,
  path    => "/home/${default_user}/Desktop",
  replace => false,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0775',
  require => [
    Package['desktop'],
    File['default_user_home'],
  ],
}

exec { 'download-desktop-background':
  command => "curl https://static.evolvedbinary.com/cityehr/cityehrwork-desktop-background.png -o ${desktop_background_image}",
  path    => '/usr/bin',
  user    => $default_user,
  creates => $desktop_background_image,
  require => [
    File['default_user_desktop_folder'],
  ],
}

ini_setting { 'desktop_background_image':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/settings.conf",
  section => 'Desktop',
  setting => 'Wallpaper',
  value   => $desktop_background_image,
  require => [
    Package['desktop'],
    Exec['download-desktop-background'],
  ],
}

ini_setting { 'desktop_background_mode':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/settings.conf",
  section => 'Desktop',
  setting => 'WallpaperMode',
  value   => 'fit',
  require => [
    Package['desktop'],
    Exec['download-desktop-background'],
  ],
}

ini_setting { 'desktop_background_color':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/settings.conf",
  section => 'Desktop',
  setting => 'BgColor',
  value   => '#f8e5bd',
  require => [
    Package['desktop'],
    Exec['download-desktop-background'],
  ],
}

file_line { 'simplify-qterminalname-1':
  ensure  => present,
  path    => '/usr/share/applications/qterminal.desktop',
  line    => 'Name=Terminal',
  match   => '^Name\=QTerminal',
  require => Package['desktop'],
}

file_line { 'simplify-qterminalname-2':
  ensure  => present,
  path    => '/usr/share/applications/qterminal.desktop',
  line    => 'Name[en_GB]=Terminal',
  match   => '^Name[en_GB]\=Qterminal',
  require => Package['desktop'],
}

file { 'qterminal-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/qterminal.desktop",
  source  => '/usr/share/applications/qterminal.desktop',
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File_line['simplify-qterminalname-1'],
    File_line['simplify-qterminalname-2'],
  ],
}

exec { 'gvfs-trust-qterminal-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/qterminal.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/qterminal.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['qterminal-desktop-shortcut'],
}

file_line { 'simplify-pcmanfm-qt-name':
  ensure  => present,
  path    => '/usr/share/applications/pcmanfm-qt.desktop',
  line    => 'Name=File Manager',
  match   => '^Name\=',
  require => Package['desktop'],
}

file { 'pcmanfm-qt-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/pcmanfm-qt.desktop",
  source  => '/usr/share/applications/pcmanfm-qt.desktop',
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File_line['simplify-pcmanfm-qt-name'],
  ],
}

exec { 'gvfs-trust-pcmanfm-qt-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/pcmanfm-qt.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/pcmanfm-qt.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['pcmanfm-qt-desktop-shortcut'],
}

file_line { 'simplify-lxqt-archiver-name':
  ensure  => present,
  path    => '/usr/share/applications/lxqt-archiver.desktop',
  line    => 'Name=File Archiver',
  match   => '^Name\=',
  require => Package['desktop'],
}

file { 'lxqt-archiver-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/lxqt-archiver.desktop",
  source  => '/usr/share/applications/lxqt-archiver.desktop',
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File_line['simplify-lxqt-archiver-name'],
  ],
}

exec { 'gvfs-trust-lxqt-archiver-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/lxqt-archiver.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/lxqt-archiver.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['lxqt-archiver-desktop-shortcut'],
}

# Position the Desktop icons
inifile::create_ini_settings( {
    'computer.desktop'      => { 'pos' => '@Point(12 12)' },
    'user-home.desktop'     => { 'pos' => '@Point(12 138)' },
    'network.desktop'       => { 'pos' => '@Point(12 264)' },
    'trash-can.desktop'     => { 'pos' => '@Point(12 390)' },
    'pcmanfm-qt.desktop'    => { 'pos' => '@Point(12 516)' },
    'lxqt-archiver.desktop' => { 'pos' => '@Point(12 642)' },
    'qterminal.desktop'     => { 'pos' => '@Point(12 768)' },
  }, {
    ensure => present,
    path => "/home/${default_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
    require => [
      Package['desktop'],
      File['pcmanfm-qt-desktop-shortcut'],
      File['lxqt-archiver-desktop-shortcut'],
      File['qterminal-desktop-shortcut'],
    ]
  }
)
