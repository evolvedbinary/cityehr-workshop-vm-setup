###
# Puppet Script for Protege on Ubuntu 22.04
###

$protege_version = '5.6.4'
$protege_path = '/opt/protege'
$protege_bin = "${protege_path}/protege"

file { $protege_path:
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
}

exec { 'download-protege-tgz':
  command => "curl -L https://github.com/protegeproject/protege-distribution/releases/download/protege-${protege_version}/Protege-${protege_version}-linux.tar.gz | tar zxv -C ${protege_path} --strip-components=1",
  path    => '/usr/bin',
  user    => 'root',
  group   => 'root',
  creates => $protege_bin,
  require => [
    Package['file'],
    Package['curl'],
    File[$protege_path]
  ],
}

$protege_desktop_shortcut = @("PROTEGE_DESKTOP_ENTRY_EOF"/L)
  [Desktop Entry]
  Version=1.0
  Type=Application
  Name=Protege
  Exec=${protege_bin}
  Icon=${protege_path}/app/Protege.ico
  Terminal=false
  StartupNotify=false
  GenericName=Protege
  | PROTEGE_DESKTOP_ENTRY_EOF

file { 'protege-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/protege.desktop",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  content => $protege_desktop_shortcut,
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File[$protege_path]
  ],
}

exec { 'gvfs-trust-protege-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/protege.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/protege.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['protege-shortcut'],
}

ini_setting { 'protege-shortcut-position':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'protege.desktop',
  setting => 'pos',
  value   => '@Point(266 264)',
  require => File['protege-shortcut'],
}
