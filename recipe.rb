%w[
  tmux
  software-properties-common
  sysstat
  dstat
].each do |pkg|
  package pkg
end

execute 'apt-get update' do
  action :nothing
end

execute 'apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D' do
  not_if 'apt-key list | grep releasedocker > /dev/null'
end

file '/etc/apt/sources.list.d/docker.list' do
  content 'deb https://apt.dockerproject.org/repo ubuntu-wily main'
  notifies :run, 'execute[apt-get update]', :immediately
end

package 'linux-image-extra-4.2.0-25-generic'

package 'docker-engine'

service 'docker' do
  action [:enable, :start]
end
