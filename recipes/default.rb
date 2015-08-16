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

tag   = node[:dokku][:tag]
root  = node[:dokku][:root]
vhost = node[:dokku][:vhost]

version_file = File.join(root, 'VERSION')
authed_file  = File.join(root, ".ssh", "authorized_keys")

version = File.exist?(version_file) && File.read(version_file)

# If dokku is not installed, or another version than the one specified is
# installed, run Dokku's boostrap.sh to ensure specified version is installed.
if !version || version.strip.gsub(/^v/i, '') != tag.strip.gsub(/^v/i, '')
  if !version
    # A SSH key is required as part of the initial installation process, so we
    # grab the first key from the first specified user. Any remaining keys are
    # also added once installation is complete.
    user      = node[:dokku][:ssh_users].first
    ssh_key   = data_bag_item('users', user).fetch('ssh_keys', []).first
    key_file  = File.join(Chef::Config[:file_cache_path], "dokku_ssh_key.pub")
    file key_file do
      content ssh_key
      action :create
    end

    bash "dokku debconf-set-selections" do
      code \
        "echo \"dokku dokku/web_config boolean false\" " +
          "| debconf-set-selections && " +
        "echo \"dokku dokku/vhost_enable boolean true\" " +
          "| debconf-set-selections && " +
        "echo \"dokku dokku/hostname string #{vhost}\" " +
          "| debconf-set-selections && " +
        "echo \"dokku dokku/key_file string #{key_file}\" " +
          "| debconf-set-selections"
    end

    log "about to install dokku, this can take upto 15 minutes or more."
  end

  bash "dokku-bootstrap" do
    code "wget -qO- https://raw.github.com/progrium/dokku/#{tag}/bootstrap.sh " +
      "| sudo DOKKU_TAG=#{tag} DOKKU_ROOT=\"#{root}\" bash"
  end
end

## loop through users adding all their keys from data_bag users if needed
node[:dokku][:ssh_users].each do |user|
  keys = data_bag_item('users', user).fetch('ssh_keys', [])
  Array(keys).each_with_index do |key, index|
    bash 'sshcommand-acl-add' do
      cwd root
      code "echo '#{key}' | sshcommand acl-add dokku #{user}-#{index}"
      not_if do
        authed_keys  = File.exist?(authed_file) && File.read(authed_file)
        escaped_name = Regexp.escape("#{user}-#{index}")
        escaped_key  = Regexp.escape(key)

        authed_keys && authed_keys =~ /^.+#{escaped_name}.+#{escaped_key}.*$/
      end
    end
  end
end

## setup domain, you need this unless host can resolve dig +short $(hostname -f)
if vhost
  file File.join(root, 'VHOST') do
    owner 'dokku'
    content vhost
    action :create
  end
end

## setup env vars for listed apps
node[:dokku][:apps].each do |app, cfg|
  directory File.join(root, app) do
    owner  'dokku'
    group  'dokku'
  end

  template File.join(root, app, 'ENV') do
    source 'ENV.erb'
    owner  'dokku'
    group  'dokku'
    variables(:env => cfg[:env] || {})
  end
end

## initial git push works better if we restart docker first
service 'docker' do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
