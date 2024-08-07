###
# Puppet Script for Okular (pdf viewer) on Ubuntu 24.04
###

package { 'okular':
  ensure => installed,
}

$ocular_mimeapp = @("OKULAR_MIMEAPP_EOF"/L)
  [Default Applications]
  application/pdf=okularApplication_pdf.desktop
  | OKULAR_MIMEAPP_EOF

file { "/home/${default_user}/.config/lxqt-mimeapps.list":
  ensure  => file,
  content => $ocular_mimeapp,
  owner   => $default_user,
  group   => $default_user,
}
