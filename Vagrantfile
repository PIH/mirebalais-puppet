# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.hostname = "vagrant-test.pih-emr.org"

  # using a specific IP.
   config.vm.network "private_network", ip: "192.168.33.101"

  # Create a public network, which generally matched to bridged network.
  #
   config.vm.provider "virtualbox" do |vb|
     vb.memory = "6096"
   end
  #
   config.vm.provision "shell", inline: "hostnamectl set-hostname vagrant-test.pih-emr.org"
   config.vm.provision "shell", inline: "apt -y update"
   config.vm.provision "shell", inline: "apt -y upgrade"
end
