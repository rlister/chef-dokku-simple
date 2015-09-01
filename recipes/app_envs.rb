## setup env vars for listed apps
node[:dokku][:apps].each do |app, cfg|
  directory File.join(node[:dokku][:root], app) do
    owner  'dokku'
    group  'dokku'
  end

  template File.join(node[:dokku][:root], app, 'ENV') do
    source 'ENV.erb'
    owner  'dokku'
    group  'dokku'
    variables(:env => cfg[:env] || {})
  end
end
