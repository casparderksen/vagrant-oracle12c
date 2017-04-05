# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "centos-6.7-x86_64"

  # Oracle Net Listener port
  config.vm.network :forwarded_port, guest: 1521, host: 1521

  # EM port
  config.vm.network :forwarded_port, guest: 5500, host: 5500

  # Create a private network
  config.vm.network "private_network", ip: "192.168.33.11"

  # VirtualBox provider configuration
  config.vm.provider "virtualbox" do |vb|
    vb.name = "CentOS 6.7 - Oracle 12c"
    vb.memory = "4096"
    vb.cpus = 2
  end

  # Perform shell script provisioning
  config.vm.provision "shell", path: "oracle/provision_preinstall.sh"
  config.vm.provision "shell", path: "oracle/provision_oracle.sh"

end
