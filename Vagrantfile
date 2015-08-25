# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.network "forwarded_port", guest: 8888, host: 8888
  config.vm.network "forwarded_port", guest: 8000, host: 8000
  config.ssh.forward_agent = true

  config.vm.provider "docker" do |d|
    d.build_dir = "./vagrant"
    d.has_ssh = true
  end

  # provisioning
  require 'rbconfig'

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "ansible/vagrant.yml"
    ansible.limit = "all"
    ansible.verbose = "v"
    #ansible.vault_password_file = "ansible/.vault_pass.txt"
    ansible.host_key_checking = false
  end

end
