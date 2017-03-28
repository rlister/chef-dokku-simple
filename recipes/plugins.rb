## download requested plugins
node[:dokku][:plugins].each do |name, url|
  target_dir = "/var/lib/dokku/plugins/#{name}"
  version = node[:dokku][:tag].strip.gsub(/^v/i, '').to_f

  if url.to_s == "remove"
    if version  < 0.4
      directory target_dir do
        recursive true
        action :delete
      end
    else
      bash 'dokku-plugins-install-v2' do
        user 'root'
        code "dokku plugin:uninstall #{name}"
        only_if "dokku plugin | grep #{name}", user: "root"
      end
    end
  else
    (url, rev) = url.split("#", 2) if url.include?("#")

    if version < 0.4
      git target_dir do
        repository url
        revision rev if rev
        action :sync
        notifies :run, 'bash[dokku-plugins-install]'
      end
    else
      bash 'dokku-plugins-install-v2' do
        user 'root'
        code "dokku plugin:install #{url}.git #{name}"
        not_if "dokku plugin | grep #{name}", user: "root"
      end
    end
  end
end

## install all plugins
bash 'dokku-plugins-install' do
  cwd '/var/lib/dokku/plugins'
  code 'dokku plugins-install'
  action :nothing
end

