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

execute 'add-apt-repository -y universe' do
  not_if 'grep -E "^deb .+ wily universe$" /etc/apt/sources.list'
end
execute 'add-apt-repository -y ppa:groonga/ppa' do
  not_if 'test -e /etc/apt/sources.list.d/groonga-ubuntu-ppa-wily.list'
  notifies :run, 'execute[apt-get update]', :immediately
end

%w[
  groonga
  groonga-tokenizer-mecab
  groonga-token-filter-stem
  groonga-httpd
].each do |pkg|
  package pkg
end

service 'groonga-httpd' do
  action [:enable, :start]
end
