authed_file  = File.join(node[:dokku][:root], ".ssh", "authorized_keys")

## loop through users adding all their keys from data_bag users if needed
node[:dokku][:ssh_users].each do |user|
  keys = data_bag_item('users', user).fetch('ssh_keys', [])
  Array(keys).each_with_index do |key, index|
    bash 'sshcommand-acl-add' do
      cwd node[:dokku][:root]
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
