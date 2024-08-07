###
# Puppet Script to reverse-proxy Guacamole Client with Nginx on Ubuntu 24.04
###

include ufw

class { 'nginx':
  package_ensure  => installed,
  service_manage  => true,
  service_name    => nginx,
  service_enable  => true,
  service_ensure  => running,
  http_raw_append => 'map $http_upgrade $connection_upgrade {
      default upgrade;
      \'\'      close;
  }',
}

nginx::resource::upstream { 'guacamole-server':
  members => {
    'localhost:8080' => {
      server => 'localhost',
      port   => 8080,
    },
  },
}

nginx::resource::server { 'plum.evolvedbinary.com':
  ensure              => present,
  access_log          => '/var/log/nginx/plum.evolvedbinary.com_access.log',
  listen_port         => 80,
  ipv6_enable         => true,
  ipv6_listen_options => '',
  ipv6_listen_port    => 80,
  ssl                 => true,
  ssl_redirect        => true,
  ssl_cert            => '/etc/letsencrypt/live/plum.evolvedbinary.com/cert.pem',
  ssl_key             => '/etc/letsencrypt/live/plum.evolvedbinary.com/privkey.pem',
  ssl_dhparam         => '/etc/letsencrypt/ssl-dhparams.pem',
  http2               => 'on',
  proxy               => 'http://guacamole-server/guacamole/',
  proxy_http_version  => '1.1',
  proxy_set_header    => [
    'Host $host',
    'Upgrade $http_upgrade',
    'Connection $connection_upgrade',
    'X-Real-IP $remote_addr',
    'X-Forwarded-For $proxy_add_x_forwarded_for',
    'nginx-request-uri $request_uri',
  ],
}

ufw::allow { 'nginx-http':
  port    => '80',
  require => Class['nginx'],
}

ufw::allow { 'nginx-https':
  port    => '443',
  require => Class['nginx'],
}

package { 'cron':
  ensure => installed,
}

class { 'letsencrypt':
  email          => 'sysops@evolvedbinary.com',
  package_ensure => 'latest',
  certificates   => {
    'plum.evolvedbinary.com' => {
      plugin      => 'nginx',
      manage_cron => true,
    },
  },
  require        => [
    Class['nginx'],
    Class['letsencrypt::plugin::nginx'],
    Package['cron']
  ],
}

class { 'letsencrypt::plugin::nginx':
  manage_package => true,
  package_name   => 'python3-certbot-nginx',
  require        => Class['nginx'],
}
