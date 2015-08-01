## download requested plugins
node[:dokku][:plugins].each do |name, url|
  target_dir = "/var/lib/dokku/plugins/#{name}"

  if url.to_s == "remove"
    directory target_dir do
      recursive true
      action :delete
    end
  else
    (url, rev) = url.split("#", 2) if url.include?("#")

    git target_dir do
      repository url
      revision rev if rev
      action :sync
      notifies :run, 'bash[dokku-plugins-install]'
    end
  end
end

## install all plugins
bash 'dokku-plugins-install' do
  cwd '/var/lib/dokku/plugins'
  code 'dokku plugins-install'
  action :nothing
end
