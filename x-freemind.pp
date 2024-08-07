###
# Puppet Script for FreeMind on Ubuntu 22.04
###

$freemind_version = '1.0.1'
$freemind_path = '/opt/freemind'
$freemind_bin = "${freemind_path}/freemind.sh"

exec { 'download-freemind-zip':
  path    => '/usr/bin',
  command => "curl -L https://deac-riga.dl.sourceforge.net/project/freemind/freemind/${freemind_version}/freemind-bin-max-${freemind_version}.zip?viasf=1 -o /tmp/freemind-bin-max-${freemind_version}.zip",
  unless  => "test -f ${freemind_bin}",
  require => [
    Package['file'],
    Package['curl'],
  ],
}

file { '/opt/freemind':
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
}

exec { 'unzip-freemind':
  command => "unzip /tmp/freemind-bin-max-${freemind_version}.zip -d ${freemind_path}",
  path    => '/usr/bin',
  user    => 'root',
  group   => 'root',
  unless  => "test -f ${freemind_bin}",
  require => [
    Package['file'],
    Package['unzip'],
    Exec['download-freemind-zip'],
    File['/opt/freemind']
  ],
}

file { 'exec-freemind-sh':
  ensure  => file,
  path    => $freemind_bin,
  replace => false,
  mode    => '0755',
  owner   => 'root',
  group   => 'root',
  require => Exec['unzip-freemind'],
}

$freemind_desktop_shortcut = @("FREEMIND_DESKTOP_ENTRY_EOF"/L)
  [Desktop Entry]
  Version=1.0
  Type=Application
  Name=FreeMind
  Exec=${freemind_bin}
  Terminal=false
  StartupNotify=false
  GenericName=FreeMind
  | FREEMIND_DESKTOP_ENTRY_EOF

file { 'freemind-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/freemind.desktop",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  content => $freemind_desktop_shortcut,
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['/opt/freemind']
  ],
}

exec { 'gvfs-trust-freemind-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/freemind.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/freemind.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['freemind-shortcut'],
}

ini_setting { 'freemind-shortcut-position':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'freemind-shortcut.desktop',
  setting => 'pos',
  value   => '@Point(266 768)',
  require => File['freemind-shortcut'],
}
