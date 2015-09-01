## setup domain, you need this unless host can resolve dig +short $(hostname -f)
if node[:dokku][:vhost]
  file File.join(node[:dokku][:root], 'VHOST') do
    owner 'dokku'
    content node[:dokku][:vhost]
    action :create
  end
end
