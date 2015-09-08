enabled_dir  = "/var/lib/dokku/plugins"
disabled_dir = "/var/lib/dokku/disabled-plugins"

node[:dokku][:plugins].each do |name, _|
  bash "enable-plugin:#{name}" do
    code "mv \"#{File.join(disabled_dir, name)}\" \"#{enabled_dir}/\""
    not_if { !File.exist?(File.join(disabled_dir, name)) }
  end
end
