###
# Puppet Script to build and install Guacamole Client on Ubuntu 24.04
###

$guacamole_client_source_folder = "/home/${default_user}/code/guacamole-client"

file { 'guacamole-client-source-folder':
  ensure  => directory,
  path    => $guacamole_client_source_folder,
  replace => false,
  owner   => $default_user,
  group   => $default_user,
  require => File['default_user_code_folder'],
}

vcsrepo { 'guacamole-client-source':
  ensure             => latest,
  path               => $guacamole_client_source_folder,
  provider           => git,
  source             => 'https://github.com/apache/guacamole-client.git',
  revision           => 'master',
  keep_local_changes => false,  # TODO(AR) change this to 'true' once https://github.com/puppetlabs/puppetlabs-vcsrepo/pull/623 is merged and released
  owner              => $default_user,
  group              => $default_user,
  require            => [
    Package['git'],
    File['guacamole-client-source-folder'],
  ],
}

exec { 'guacamole-client-compile':
  cwd      => $guacamole_client_source_folder,
  command  => '/opt/maven/bin/mvn package',
  provider => shell,
  user     => $default_user,
  creates  => "${guacamole_client_source_folder}/target",
  require  => [
    Vcsrepo['guacamole-client-source'],
    Package['openjdk-17-jdk-headless'],
    File['/opt/maven'],
  ],
}

file { '/etc/guacamole':
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
  mode    => '0755',
}

file { '/etc/guacamole/lib':
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
  mode    => '0755',
  require => File['/etc/guacamole'],
}

file { '/etc/guacamole/extensions':
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
  mode    => '0755',
  require => File['/etc/guacamole'],
}

$guacamole_properties = @("GUACAMOLE_PROPERTIES_EOF"/L)
  allowed-languages: en
  guacd-hostname: localhost
  guacd-port: 4822
  | GUACAMOLE_PROPERTIES_EOF

file { '/etc/guacamole/guacamole.properties':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0744',
  content => $guacamole_properties,
  require => File['/etc/guacamole'],
}

$user_mapping = @("USER_MAPPING_EOF":xml/L)
  <user-mapping>
      <authorize username="cityehrwork1" password="cityehrwork">
          <connection name="cityehrwork1">
              <protocol>rdp</protocol>
              <param name="hostname">cityehrwork1.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${cityehrwork_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
      <authorize username="cityehrwork2" password="cityehrwork">
          <connection name="cityehrwork2">
              <protocol>rdp</protocol>
              <param name="hostname">cityehrwork2.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${cityehrwork_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
      <authorize username="cityehrwork3" password="cityehrwork">
          <connection name="cityehrwork3">
              <protocol>rdp</protocol>
              <param name="hostname">cityehrwork3.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${cityehrwork_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
      <authorize username="cityehrwork4" password="cityehrwork">
          <connection name="cityehrwork4">
              <protocol>rdp</protocol>
              <param name="hostname">cityehrwork4.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${cityehrwork_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
      <authorize username="cityehrwork5" password="cityehrwork">
          <connection name="cityehrwork5">
              <protocol>rdp</protocol>
              <param name="hostname">cityehrwork5.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${cityehrwork_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
      <authorize username="cityehrwork6" password="cityehrwork">
          <connection name="cityehrwork6">
              <protocol>rdp</protocol>
              <param name="hostname">cityehrwork6.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${cityehrwork_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
          <authorize username="cityehrwork7" password="cityehrwork">
          <connection name="cityehrwork7">
              <protocol>rdp</protocol>
              <param name="hostname">cityehrwork7.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${cityehrwork_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
          <authorize username="cityehrwork8" password="cityehrwork">
          <connection name="cityehrwork8">
              <protocol>rdp</protocol>
              <param name="hostname">cityehrwork8.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${cityehrwork_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
  </user-mapping>
  | USER_MAPPING_EOF

file { '/etc/guacamole/user-mapping.xml':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0744',
  content => $user_mapping,
  require => File['/etc/guacamole'],
}

$tomcat_packages = ['tomcat9', 'tomcat9-admin', 'tomcat9-user']
package { $tomcat_packages:
  ensure  => installed,
  require => Package['openjdk-17-jdk-headless'],
}

file { 'guacamole-war':
  ensure  => file,
  path    => '/var/lib/tomcat9/webapps/guacamole.war',
  source  => "${guacamole_client_source_folder}/guacamole/target/guacamole-1.5.5.war",
  require => [
    File['/etc/guacamole/guacamole.properties'],
    File['/etc/guacamole/user-mapping.xml'],
    File['/etc/guacamole/lib'],
    File['/etc/guacamole/extensions'],
    Exec['guacamole-client-compile'],
    Package['tomcat9'],
  ],
}

service { 'tomcat9':
  ensure  => running,
  enable  => true,
  require => [
    File['guacamole-war'],
    Package['tomcat9'],
  ],
}
