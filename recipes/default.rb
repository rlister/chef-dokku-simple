#
# Cookbook Name:: dokku-simple
# Recipe:: default
#
# Copyright 2014, Ric Lister
#
# All rights reserved - Do Not Redistribute
#

## to get the bootstrap script
package 'wget'

## make sure we have apt-add-repository
package 'python-software-properties'
package 'software-properties-common'

tag  = node[:dokku][:tag]
root = node[:dokku][:root]
version = File.join(root, 'VERSION')

## run default dokku install
bash 'dokku-bootstrap' do
  code "wget -qO- https://raw.github.com/progrium/dokku/v0.2.2/bootstrap.sh | sudo DOKKU_TAG=#{tag} DOKKU_ROOT=#{root} bash"
  not_if do
    File.exists?(version) and (File.open(version).read.chomp == tag)
  end
end

## loop through users adding all their keys from data_bag users
node[:dokku][:ssh_users].each do |user|
  keys = data_bag_item('users', user).fetch('ssh_keys', [])
  Array(keys).each_with_index do |key, index|
    bash 'sshcommand-acl-add' do
      cwd root
      code "echo '#{key}' | sshcommand acl-add dokku #{user}-#{index}"
    end
  end
end

## setup domain, you need this unless host can resolve dig +short $(hostname -f) 
vhost = node[:dokku][:vhost]
if vhost
  file File.join(root, 'VHOST') do
    owner 'dokku'
    content vhost
    action :create
  end
end
