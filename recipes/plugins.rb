## download requested plugins
node[:dokku][:plugins].each do |name, url|

  git "/var/lib/dokku/plugins/#{name}" do
    repository url
    action :checkout
    notifies :run, 'bash[dokku-plugins-install]'
  end

end

## install all plugins
bash 'dokku-plugins-install' do
  cwd '/var/lib/dokku/plugins'
  code 'dokku plugins-install'
  action :nothing
end
