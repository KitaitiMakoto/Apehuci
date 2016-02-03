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
