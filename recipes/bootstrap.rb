## to get the bootstrap script
package "wget"

## make sure we have apt-add-repository
package "python-software-properties"
package "software-properties-common"

url = "https://raw.github.com/progrium/dokku/#{node[:dokku][:tag]}/bootstrap.sh"

bash "dokku-bootstrap" do
  code "wget -qO- #{url} | sudo DOKKU_TAG=#{node[:dokku][:tag]} " +
    "DOKKU_ROOT=\"#{node[:dokku][:root]}\" bash"
end
