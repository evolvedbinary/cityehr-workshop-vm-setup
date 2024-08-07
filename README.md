# cityEHR Workshop - Virtual Machine

The following instructions will configure a Virtual Machine for the purposes of teaching a cityEHR workshop.

By the following these instructions you will have a Virtual Environment with the following software configured:

* Ubuntu 24.04 (x86_64)

* Desktop Environment
	* X.org
	* LXQt
	* Chromium
	* Firefox

* Java Development Environment
	* JDK 11
	* JDK 17
	* Apache Maven 3
	* IntelliJ IDEA CE
	* Apache Tomcat 9

* Database Environment
	* MariaDB Server and Client
	* MySQL Workbench
	* DBeaver

* cityEHR

* cityEHR Workshop Tools
	* Oxygen XML Editor
	* LibreOffice
	* Protégé
	* Inkscape
	* GanttProject
	* FreeMind
	* BOUML

* Visual Studio Code

* Miscellaneous Tools
	* Zsh and OhMyZsh
	* Git
	* cURL
	* wget
	* Screen
	* tar, gzip, bzip2, zstd, zip (and unzip)


We expect to start from a clean Ubuntu Server, or Ubuntu Cloud Image install. This has been tested with Ubuntu version 24.04 LTS.


This can be setup either in AWS EC2, or another Virtual Environment such as KVM on Linux.


## Setting up a new AWS EC2 Instance

If you wish to set this up in AWS EC2, then you should setup a new EC2 instance with the following properties:

1. Name the instance 'cityehrwork1'.

2. Select the `Ubuntu Server 24.04 LTS (HVM), SSD Volume Type` AMI image, and the Architecture `amd64`.

3. Select `m6g.xlarge` instance type. (i.e.: 4vCPU, 16GB Memory, 1x237 NVMe SSD, $0.1776 / hour).

4. Select the `cityehrwork` keypair.

5. Select the `cityehrwork vm` Security Group.

6. Set the default Root Volume as an `EBS` `30 GiB` volume on `GP3` at `3000 IOPS` and `125 MiB throughput`.


## Setting up a new Linux KVM VM

If you wish to set this up in a KVM VM, then on the KVM host (assuming Ubuntu as the host OS) you should run the following commands (assuming an Evolved Binary Server in Hetzner):

```
git clone --single-branch --branch hetzner https://github.com/adamretter/soyoustart hetzner
cd ~/hetzner
sudo uvt-simplestreams-libvirt sync --source=http://cloud-images.ubuntu.com/minimal/releases arch=amd64 release=noble
./create-uvt-kvm.sh --hostname cityehrwork1 --release noble --memory 16384 --disk 30 --cpu 4 --bridge virbr1 --ip 5.9.214.101 --ip6 2a01:4f8:212:be9::101 --gateway 136.243.43.238 --gateway6 2a01:4f8:212:be9::2 --dns 213.133.100.100 --dns 213.133.99.99 --dns 213.133.98.98 --dns-search evolvedbinary.com --autostart
```

NOTE: The VM specific settings are:
* `--hostname` `cityehrwork1`
* `--ip` `5.9.214.101`
* `--ip6` `2a01:4f8:212:be9::101`

NOTE: The network settings specific to the host are:
* `--bridge` `virbr1`
* `--gateway` `136.243.43.238`
* `--gateway6` `2a01:4f8:212:be9::2`

NOTE: The network settings specific to the hosting provider are:
* `--dns 213.133.100.100`, `--dns 213.133.99.99`, `--dns 213.133.98.98`



## Installing and Running Puppet to Configure the VM

```
git clone https://github.com/evolvedbinary/cityehr-workshop-vm-setup.git
cd cityehr-workshop-vm-setup
rm -rf guacamole
sudo ./install-puppet-agent.sh

sudo /opt/puppetlabs/bin/puppet apply locale-gb.pp

sudo FACTER_default_user_password=mypassword \
     /opt/puppetlabs/bin/puppet apply base.pp
```

* `default_user_password` this is the password to set for the default linux user (typically the user is named `ubuntu` on Ubuntu Cloud images).

**NOTE:** you should set your own passwords appropriately above!

We have to restart the system after the above as it may install a new Kernel and make changes to settings that require a system reboot. So:

```
sudo shutdown -r now
```

After the system restarts and you have logged in, you need to resume from the `cityehr-workshop-vm-setup` repo checkout:

```
cd cityehr-workshop-vm-setup
sudo FACTER_default_user_password=mypassword \
     FACTER_mariadb_db_root_password=cityehrwork \
     /opt/puppetlabs/bin/puppet apply .
```

* `default_user_password` this is the password to set for the default linux user (typically the user is named `ubuntu` on Ubuntu Cloud images).
* `mariadb_db_root_password` - This is the password to set for the `root` user in MariaDB.

**NOTE:** you should set your own passwords appropriately above!

We have to restart the system after the above as it installs a new desktop login manager.

```
sudo shutdown -r now
```

(-[1-9A-Za-z-][0-9A-Za-z-]*(\.[1-9A-Za-z-][0-9A-Za-z-]*)*)?


### Load the data into the db

TODO(AR)

## Install Guacamole Server

On a separate VM:

```
git clone https://github.com/evolvedbinary/cityehr-workshop-vm-setup.git
cd cityehr-workshop-vm-setup
sudo ./install-puppet-agent.sh

cd guacamole

sudo FACTER_default_user_password=mypassword2 \
     /opt/puppetlabs/bin/puppet apply base.pp
```

**NOTE:** you should set your own passwords appropriately above!

We have to restart the system after the above as it may install a new Kernel and make changes to settings that require a system reboot. So:

```
sudo shutdown -r now
```

After the system restarts and you have logged in, you need to resume from the `cityehr-workshop-vm-setup/guacamole` repo checkout:

```
cd cityehr-workshop-vm-setup/guacamole

sudo FACTER_default_user_password=mypassword2 \
     FACTER_cityehrwork_default_user_password=mypassword
     /opt/puppetlabs/bin/puppet apply .
```

