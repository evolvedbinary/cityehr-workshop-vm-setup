###
# Puppet Script for configuring LXQT Panel Shortcuts on Ubuntu 24.04
###

file { 'dot-config':
  ensure  => directory,
  path    => "/home/${default_user}/.config",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0700',
  require => Package['desktop'],
}

file { 'dot-config-lxqt':
  ensure  => directory,
  path    => "/home/${default_user}/.config/lxqt",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0700',
  require => [
    Package['desktop'],
    File['dot-config'],
  ],
}

$panel_conf = @("PANEL_EOF"/L)
  [General]
  __userfile__=true

  [desktopswitch]
  alignment=Left
  type=desktopswitch

  [mainmenu]
  alignment=Left
  type=mainmenu

  [mount]
  alignment=Right
  type=mount

  [panel1]
  alignment=-1
  animation-duration=0
  background-color=@Variant(\0\0\0\x43\0\xff\xff\0\0\0\0\0\0\0\0)
  background-image=
  desktop=0
  font-color=@Variant(\0\0\0\x43\0\xff\xff\0\0\0\0\0\0\0\0)
  hidable=false
  hide-on-overlap=false
  iconSize=22
  lineCount=1
  lockPanel=false
  opacity=100
  panelSize=32
  position=Bottom
  reserve-space=true
  show-delay=0
  visible-margin=true
  width=100
  width-percent=true

  [quicklaunch]
  alignment=Left
  apps\1\desktop=/home/${default_user}/Desktop/google-chrome.desktop
  apps\1\desktop=/home/${default_user}/Desktop/firefox.desktop
  apps\2\desktop=/home/${default_user}/Desktop/qterminal.desktop
  apps\3\desktop=/home/${default_user}/Desktop/pcmanfm-qt.desktop
  apps\size=3
  type=quicklaunch

  [showdesktop]
  alignment=Right
  type=showdesktop

  [statusnotifier]
  alignment=Right
  type=statusnotifier

  [taskbar]
  alignment=Left
  type=taskbar

  [tray]
  alignment=Right
  type=tray

  [volume]
  alignment=Right
  type=volume

  [worldclock]
  alignment=Right
  type=worldclock

  | PANEL_EOF

file { 'panel':
  ensure  => file,
  replace => true,
  path    => "/home/${default_user}/.config/lxqt/panel.conf",
  content => $panel_conf,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0664',
  require => [
    Package['desktop'],
    File['dot-config-lxqt'],
    File['google-chrome-desktop-shortcut'],
    File['firefox-desktop-shortcut'],
  ],
}
