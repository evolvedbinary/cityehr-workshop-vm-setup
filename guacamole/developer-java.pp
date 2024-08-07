###
# Puppet Script for a Java Developer Environment on Ubuntu 24.04
###

$maven_version = '3.9.8'

package { 'openjdk-17-jdk-headless':
  ensure => installed,
}

file_line { 'JAVA_HOME':
  ensure  => present,
  path    => '/etc/environment',
  line    => 'JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64',
  match   => '^JAVA_HOME\=',
  require => Package['openjdk-17-jdk-headless'],
}

exec { 'install-maven':
  command => "curl -L https://archive.apache.org/dist/maven/maven-3/${maven_version}/binaries/apache-maven-${maven_version}-bin.tar.gz | tar zxv -C /opt",
  path    => '/usr/bin',
  user    => 'root',
  creates => "/opt/apache-maven-${maven_version}",
  require => Package['curl'],
}

file { '/opt/maven':
  ensure  => link,
  target  => "/opt/apache-maven-${maven_version}",
  replace => false,
  owner   => 'root',
  group   => 'root',
  require => Exec['install-maven'],
}

file_line { 'MAVEN_HOME':
  ensure  => present,
  path    => '/etc/environment',
  line    => 'MAVEN_HOME=/opt/maven',
  match   => '^MAVEN_HOME\=',
  require => File['/opt/maven'],
}

file_line { 'PATH':
  ensure  => present,
  path    => '/etc/environment',
  line    => 'PATH=/opt/maven/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin',
  match   => '^PATH\=',
  require => File['/opt/maven'],
}
