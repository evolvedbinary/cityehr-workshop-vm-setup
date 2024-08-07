###
# Puppet Script for Tomcat 9 on Ubuntu 24.04
###

$tomcat_version = '9.0.93'
$tomcat_user = 'tomcat'
$tomcat_path = "/opt/tomcat-${tomcat_version}"
$tomcat_alias = '/opt/tomcat'

group { $tomcat_user:
  ensure => present,
  system => true,
}

user { $tomcat_user:
  ensure     => present,
  gid        => $tomcat_user,
  comment    => 'Apache Tomcat Server system account',
  managehome => false,
  shell      => '/bin/false',
  system     => true,
  require    => Group[$tomcat_user],
}

file { $tomcat_path:
  ensure  => directory,
  replace => false,
  owner   => $tomcat_user,
  group   => $tomcat_user,
  require => User[$tomcat_user],
}

file { $tomcat_alias:
  ensure  => link,
  target  => $tomcat_path,
  replace => false,
  owner   => $tomcat_user,
  group   => $tomcat_user,
  require => File[$tomcat_path],
}

exec { 'install-tomcat':
  command => "curl https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.93/bin/apache-tomcat-9.0.93.tar.gz | tar zxv -C ${tomcat_path} --strip-components=1",
  path    => '/usr/bin',
  user    => $tomcat_user,
  creates => "${tomcat_path}/bin/catalina.sh",
  require => [
    File[$tomcat_path],
    Package['curl'],
    Package['openjdk-11-jdk'],
  ],
}

file { '/var/run/tomcat':
  ensure => directory,
  owner  => $tomcat_user,
  group  => $tomcat_user,
  mode   => '0664',
}

$tomcat_service_unit = @("TOMCAT_SERVICE_UNIT_EOF"/L)
  [Unit]
  Description=Apache Tomcat Web Application Container
  After=network.target

  [Service]
  Type=forking
  User=${tomcat_user}
  Group=${tomcat_user}
  Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
  Environment="_JAVA_OPTIONS="
  Environment="CATALINA_HOME=${tomcat_alias}"
  Environment="CATALINA_PID=/var/run/tomcat/tomcat.pid"
  Environment="CATALINA_OPTS=-Xms512M -Xmx8192M"
  ExecStart=${tomcat_alias}/bin/startup.sh
  ExecStop=${tomcat_alias}/bin/shutdown.sh

  [Install]
  WantedBy=multi-user.target
  | TOMCAT_SERVICE_UNIT_EOF

file { '/etc/systemd/system/tomcat.service':
  ensure  => file,
  content => $tomcat_service_unit,
  require => [
    User[$tomcat_user],
    Exec['install-tomcat'],
    File[$tomcat_alias],
  ],
} ~> exec { 'systemd-reload-tomcat':
  command => 'systemctl daemon-reload',
  path    => '/usr/bin',
  user    => 'root',
}

service { 'tomcat':
  ensure  => running,
  enable  => true,
  require => [
    File['/var/run/tomcat'],
    File['/etc/systemd/system/tomcat.service'],
    Exec['systemd-reload-tomcat'],
    Package['openjdk-11-jdk'],
  ],
}
