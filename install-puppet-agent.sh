#!/usr/bin/env bash

set -e

if [ -n "$(command -v rpm)" ]; then
	rpm -Uvh https://yum.puppet.com/puppet7-release-el-7.noarch.rpm
	yum -y install puppet-agent
elif [ -n "$(command -v dpkg)" ]; then
	pushd /tmp
	wget https://apt.puppetlabs.com/puppet7-release-jammy.deb
	dpkg -i puppet7-release-jammy.deb
	rm puppet7-release-jammy.deb
	popd
	apt-get update
	apt-get install -y puppet-agent
else
	echo "Could not locate rpm or dpkg"
	exit 1
fi

/opt/puppetlabs/bin/puppet module install puppetlabs-stdlib
/opt/puppetlabs/bin/puppet module install saz-ssh
/opt/puppetlabs/bin/puppet module install domkrm-ufw
/opt/puppetlabs/bin/puppet module install puppetlabs-sshkeys_core
/opt/puppetlabs/bin/puppet module install puppetlabs-vcsrepo
/opt/puppetlabs/bin/puppet module install puppetlabs-augeas_core
/opt/puppetlabs/bin/puppet module install puppetlabs-inifile
/opt/puppetlabs/bin/puppet module install puppet-nginx
/opt/puppetlabs/bin/puppet module install puppet-letsencrypt

if [ -n "$(command -v yum)" ]; then
	/opt/puppetlabs/bin/puppet module install puppet-yum
elif [ -n "$(command -v apt)" ]; then
	/opt/puppetlabs/bin/puppet module install puppetlabs-apt
fi

