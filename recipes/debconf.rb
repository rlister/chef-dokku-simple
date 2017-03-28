# A SSH key is required as part of the initial installation process, so we
# grab the first key from the first specified user. Any remaining keys are
# also added once installation is complete.
first_user = node[:dokku][:ssh_users].first
ssh_key    = Array(data_bag_item('users', first_user).fetch('ssh_keys', [])).first
key_file   = File.join(Chef::Config[:file_cache_path], "dokku_ssh_key.pub")

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
    "echo \"dokku dokku/hostname string #{node[:dokku][:vhost]}\" " +
      "| debconf-set-selections && " +
    "echo \"dokku dokku/key_file string #{key_file}\" " +
      "| debconf-set-selections"
end
