enabled_dir  = "/var/lib/dokku/plugins"
disabled_dir = "/var/lib/dokku/disabled-plugins"

node[:dokku][:plugins].each do |name, _|
  bash "disable-plugin:#{name}" do
    code "mkdir -p \"#{disabled_dir}/\"; " +
      "mv \"#{File.join(enabled_dir, name)}\" \"#{disabled_dir}/\""
    not_if { !File.exist?(File.join(enabled_dir, name)) }
  end
end
