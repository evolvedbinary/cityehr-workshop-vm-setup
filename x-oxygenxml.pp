###
# Puppet Script for oXygen XML Editor on Ubuntu 24.04
###

$oxygen_version = '26.0'

file { "/opt/oxygen-${oxygen_version}":
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
}

exec { 'install-oxygen':
  command => "curl https://mirror.oxygenxml.com/InstData/Editor/All/oxygen.tar.gz | tar zxv -C /opt/oxygen-${oxygen_version} --strip-components=1",
  path    => '/usr/bin',
  user    => 'root',
  creates => "/opt/oxygen-${oxygen_version}/oxygen.sh",
  require => [
    File["/opt/oxygen-${oxygen_version}"],
    Package['curl']
  ],
}

file { '/opt/oxygen':
  ensure  => link,
  target  => "/opt/oxygen-${oxygen_version}",
  replace => false,
  owner   => 'root',
  group   => 'root',
  require => File["/opt/oxygen-${oxygen_version}"],
}

$oxygen_desktop_shortcut = @("OXYGEN_DESKTOP_ENTRY_EOF"/L)
  [Desktop Entry]
  Version=1.0
  Type=Application
  Name=Oxygen XML Editor
  Exec=/opt/oxygen/oxygen.sh
  Icon=/opt/oxygen/Oxygen128.png
  Terminal=false
  StartupNotify=false
  GenericName=Oxygen XML Editor
  | OXYGEN_DESKTOP_ENTRY_EOF

file { 'oxygen-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/oxygen.desktop",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  content => $oxygen_desktop_shortcut,
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['/opt/oxygen']
  ],
}

exec { 'gvfs-trust-oxygen-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/oxygen.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/oxygen.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['oxygen-desktop-shortcut'],
}

ini_setting { 'oxygen-desktop-shortcut-position':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'oxygen.desktop',
  setting => 'pos',
  value   => '@Point(139 642)',
  require => File['oxygen-desktop-shortcut'],
}

# oXygen License file
file { 'oxygen-user-settings-path':
  ensure  => directory,
  path    => "/home/${default_user}/.com.oxygenxml",
  replace => false,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0775',
}

$oxygen_license_xml = @(OXYGEN_LICENSE_XML_EOF:xml/L)
  <?xml version="1.0" encoding="UTF-8"?>
  <serialized xml:space="preserve">
    <serializableOrderedMap>
      <entry>
        <String>license.26</String>
        <String>------START-LICENSE-KEY------

Registration_Name=Evolved Binary - trial

Company=Evolved Binary

Category=Enterprise

Component=XML-Editor, XSLT-Debugger, Saxon-SA

Version=26

Number_of_Licenses=10

Date=02-09-2024

Trial=35

SGN=MCwCFCCKQhNd3MTGOTv9j7m+bZ+3RaHzAhQXSepcF2MY6Zc/XmEiRvgr1J89Ew\=\=

-------END-LICENSE-KEY-------</String>
      </entry>
    </serializableOrderedMap>
  </serialized>
  | OXYGEN_LICENSE_XML_EOF

file { 'oxygen-license':
  ensure  => file,
  path    => "/home/${default_user}/.com.oxygenxml/license.xml",
  replace => false,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0664',
  content => $oxygen_license_xml,
  require => File['oxygen-user-settings-path'],
}
