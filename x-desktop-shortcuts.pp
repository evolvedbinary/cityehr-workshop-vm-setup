###
# Puppet Script for extra Desktop Shortcuts on Ubuntu 24.04
###

file { 'dot-local':
  ensure  => directory,
  path    => "/home/${default_user}/.local",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0700',
  require => Package['desktop'],
}

file { 'dot-local-share':
  ensure  => directory,
  path    => "/home/${default_user}/.local/share",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0700',
  require => [
    Package['desktop'],
    File['dot-local'],
  ],
}

file { 'local-icons':
  ensure  => directory,
  path    => "/home/${default_user}/.local/share/icons",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0755',
  require => [
    Package['desktop'],
    File['dot-local-share'],
  ],
}

exec { 'download-eb-favicon-logo':
  command => "wget -O /home/${default_user}/.local/share/icons/eb-favicon-logo.svg https://evolvedbinary.com/images/icons/shape-icon.svg",
  path    => '/usr/bin',
  creates => "/home/${default_user}/.local/share/icons/eb-favicon-logo.svg",
  user    => $default_user,
  require => [
    File['local-icons'],
    Package['wget'],
  ],
}

$eb_desktop_shortcut =  @("EB_SHORTCUT_EOF"/L)
  [Desktop Entry]
  Version=1.0
  Name=Evolved Binary
  Exec=/usr/bin/google-chrome-stable https://www.evolvedbinary.com
  StartupNotify=true
  Terminal=false
  Icon=/home/${default_user}/.local/share/icons/eb-favicon-logo.svg
  Type=Application
  | EB_SHORTCUT_EOF

file { 'eb-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/evolved-binary.desktop",
  content => $eb_desktop_shortcut,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    Package['google-chrome-stable'],
    Exec['download-eb-favicon-logo'],
  ],
}

exec { 'gvfs-trust-eb-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/evolved-binary.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/evolved-binary.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['eb-desktop-shortcut'],
}

ini_setting { 'eb-desktop-shortcut-position':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'evolved-binary.desktop',
  setting => 'pos',
  value   => '@Point(393 264)',
  require => File['eb-desktop-shortcut'],
}

exec { 'download-ohi-logo':
  command => "wget -O /home/${default_user}/.local/share/icons/ohi-logo.png https://openhealthinformatics.com/wp-content/uploads/2024/05/cropped-logo-150x150.png",
  path    => '/usr/bin',
  creates => "/home/${default_user}/.local/share/icons/ohi-logo.png",
  user    => $default_user,
  require => [
    File['local-icons'],
    Package['wget'],
  ],
}

$ohi_desktop_shortcut =  @("OHI_SHORTCUT_EOF"/L)
  [Desktop Entry]
  Version=1.0
  Name=Open Health Informatics
  Exec=/usr/bin/google-chrome-stable https://openhealthinformatics.com
  StartupNotify=true
  Terminal=false
  Icon=/home/${default_user}/.local/share/icons/ohi-logo.png
  Type=Application
  | OHI_SHORTCUT_EOF

file { 'ohi-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/open-health-informatics.desktop",
  content => $ohi_desktop_shortcut,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    Package['google-chrome-stable'],
    Exec['download-ohi-logo'],
  ],
}

exec { 'gvfs-trust-ohi-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/open-health-informatics.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/open-health-informatics.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['ohi-desktop-shortcut'],
}

ini_setting { 'ohi-desktop-shortcut-position':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'open-health-informatics.desktop',
  setting => 'pos',
  value   => '@Point(393 138)',
  require => File['ohi-desktop-shortcut'],
}
