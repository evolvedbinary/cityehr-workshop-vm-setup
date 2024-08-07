###
# Puppet Script for MariaDB on Ubuntu 22.04
#
# Expects Parameters:
#     * mariadb_db_root_password
###

package { 'mariadb-server':
  ensure  => installed,
}

package { 'mariadb-client':
  ensure  => installed,
  require => Package['mariadb-server'],
} ~> exec { 'set-mariadb-password':
  command => "/usr/bin/mariadb --batch --execute \"ALTER USER 'root'@'localhost' IDENTIFIED BY '${mariadb_db_root_password}'; flush privileges;\"",
  onlyif  => '/usr/bin/mariadb --batch --execute "select count(*)"',
  user    => 'root',
  require => Service['mariadb'],
}

service { 'mariadb':
  ensure  => running,
  require => Package['mariadb-server'],
}

# Install MariaDB JDBC driver - /usr/share/java/mariadb-java-client.jar
## JDBC connection string - jdbc:mariadb://localhost:3306/<database>
package { 'libmariadb-java':
  ensure  => installed,
  require => Package['mariadb-server'],
}
