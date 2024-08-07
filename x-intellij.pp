###
# Puppet Script for IntelliJ IDEA CE on Ubuntu 24.04
###

$intellij_idea_version = '2023.3.3'

file { "/opt/idea-IC-${intellij_idea_version}":
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
}

exec { 'install-intellij-ce':
  command => "curl -L https://download.jetbrains.com/idea/ideaIC-${intellij_idea_version}.tar.gz | tar zxv -C /opt/idea-IC-${intellij_idea_version} --strip-components=1",
  path    => '/usr/bin',
  user    => 'root',
  creates => "/opt/idea-IC-${intellij_idea_version}/bin/idea.sh",
  require => [
    File["/opt/idea-IC-${intellij_idea_version}"],
    Package['curl']
  ],
}

file { '/opt/idea-IC':
  ensure  => link,
  target  => "/opt/idea-IC-${intellij_idea_version}",
  replace => false,
  owner   => 'root',
  group   => 'root',
  require => File["/opt/idea-IC-${intellij_idea_version}"],
}

$intellij_desktop_shortcut = @("INTELLIJ_DESKTOP_ENTRY_EOF"/L)
  [Desktop Entry]
  Version=1.0
  Type=Application
  Name=IntelliJ IDEA CE
  Exec=/opt/idea-IC/bin/idea.sh
  Icon=/opt/idea-IC/bin/idea.svg
  Terminal=false
  StartupNotify=false
  GenericName=IntelliJ IDEA CE
  | INTELLIJ_DESKTOP_ENTRY_EOF

file { 'intellij-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/intellij.desktop",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  content => $intellij_desktop_shortcut,
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['/opt/idea-IC'],
  ],
}

exec { 'gvfs-trust-intellij-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/intellij.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/intellij.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['intellij-desktop-shortcut'],
}

ini_setting { 'intellij-desktop-shortcut-position':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'intellij.desktop',
  setting => 'pos',
  value   => '@Point(266 390)',
  require => File['intellij-desktop-shortcut'],
}
