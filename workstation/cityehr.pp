###
# Puppet Script for cityEHR on Ubuntu 24.04
###

$cityehr_version = '1.8.0-SNAPSHOT'
$cityehr_war_path = '/opt/tomcat/webapps/cityehr.war'
$cityehr_quickstart = '2024-08-05_cityEHR_QuickStart.pdf'

$firefox_profile_id = 'ki59z67a'

exec { 'download-cityehr':
  command => "curl -L https://openhealthinformatics.com/wp-content/resources/cityehr-webapp-${cityehr_version}.war -o ${cityehr_war_path}",
  path    => '/usr/bin',
  user    => 'tomcat',
  group   => 'tomcat',
  creates => $cityehr_war_path,
  require => [
    Package['file'],
    Package['curl'],
    Service['tomcat']
  ],
}

exec { 'download-cityehr-quickstart-guide':
  command => "curl -L https://static.evolvedbinary.com/cityehr/${cityehr_quickstart} -o /home/${default_user}/Desktop/cityEHR_QuickStart.pdf",
  path    => '/usr/bin',
  user    => $default_user,
  group   => $default_user,
  creates => "/home/${default_user}/Desktop/cityEHR_QuickStart.pdf",
  require => [
    Package['file'],
    Package['curl'],
    File['default_user_desktop_folder'],
  ],
}

# Set homepage for cityEHR

file { "/home/${default_user}/snap":
  ensure => directory,
  owner  => $default_user,
  group  => $default_user,
  mode   => '0700',
}

file { "/home/${default_user}/snap/firefox":
  ensure  => directory,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0755',
  require => File["/home/${default_user}/snap"],
}

file { "/home/${default_user}/snap/firefox/common":
  ensure  => directory,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0755',
  require => File["/home/${default_user}/snap/firefox"],
}

file { "/home/${default_user}/snap/firefox/common/.mozilla":
  ensure  => directory,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0700',
  require => File["/home/${default_user}/snap/firefox/common"],
}

file { "/home/${default_user}/snap/firefox/common/.mozilla/firefox":
  ensure  => directory,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0700',
  require => File["/home/${default_user}/snap/firefox/common/.mozilla"],
}

file { "/home/${default_user}/snap/firefox/common/.mozilla/firefox/profiles.ini":
  ensure  => file,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0664',
  content => "[Profile0]
Name=default
IsRelative=1
Path=${firefox_profile_id}.default
Default=1

[General]
StartWithLastProfile=1
Version=2",
  require => [
    File["/home/${default_user}/snap/firefox/common/.mozilla/firefox"],
    Exec['download-cityehr'],
    Package['firefox'],
  ],
}

file { "/home/${default_user}/snap/firefox/common/.mozilla/firefox/${firefox_profile_id}.default":
  ensure  => directory,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0700',
  require => File["/home/${default_user}/snap/firefox/common/.mozilla/firefox"],
}

file { "/home/${default_user}/snap/firefox/common/.mozilla/firefox/${firefox_profile_id}.default/prefs.js":
  ensure  => file,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0600',
  require => File["/home/${default_user}/snap/firefox/common/.mozilla/firefox/${firefox_profile_id}.default"],
}

file_line { 'firefox-home-page':
  ensure  => present,
  path    => "/home/${default_user}/snap/firefox/common/.mozilla/firefox/${firefox_profile_id}.default/prefs.js",
  line    => 'user_pref("browser.startup.homepage", "http://localhost:8080/cityehr");',
  match   => '^user_pref\("browser\.startup\.homepage"',
  require => [
    File["/home/${default_user}/snap/firefox/common/.mozilla/firefox/${firefox_profile_id}.default/prefs.js"],
    Exec['download-cityehr'],
    Package['firefox'],
  ],
}
