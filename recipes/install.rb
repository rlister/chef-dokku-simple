tag          = node[:dokku][:tag]
version_file = File.join(node[:dokku][:root], 'VERSION')
version      = File.exist?(version_file) && File.read(version_file)

if !version || version.strip.gsub(/^v/i, '') != tag.strip.gsub(/^v/i, '')
  # Due to an issue with Dokku's installation process, we currently need to
  # disable 3rd-party plugins to avoid any potential issues.
  include_recipe "dokku-simple::debconf"
  include_recipe "dokku-simple::bootstrap"
end
