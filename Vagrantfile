# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = 'base'
  config.vm.network :forwarded_port, host: 8080, guest: 80
  
  ## if we have an old box, fix it up to make sure up to date packages are available
  config.vm.provision :shell, inline: 'sudo apt-get update'
  
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = '..'
    chef.data_bags_path = 'data_bags'
    chef.add_recipe 'dokku-simple'
    chef.json = {
      dokku: {
        ssh_users: 'ric',
        vhost: 'dokku.me',
        apps: {
          test_app: {
            env: { test: '123' }
          }
        }
      }
    }
  end

end
