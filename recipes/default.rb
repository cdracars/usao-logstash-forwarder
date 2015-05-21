#
# Cookbook Name:: usao-logstash-forwarder
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

execute "Move SSL Certs" do
  command "scp /etc/pki/tls/certs/logstash-forwarder.crt #{node['usao-logstash-forwarder']['server']['username']}@#{node['usao-logstash-forwarder']['server']['name']}:/tmp"
end

apt_repository 'logstashforwarder' do
  uri 'http://packages.elasticsearch.org/logstashforwarder/debian'
  components ['main']
  distribution 'stable'
  key 'D88E42B4'
  keyserver 'pgp.mit.edu'
end

package 'logstash-forwarder' do
  action :install
end

execute "Make certs directory" do
  command "sudo mkdir -p /etc/pki/tls/certs"
end
execute "Move certs into place" do
  command "sudo cp /tmp/logstash-forwarder.crt /etc/pki/tls/certs/"
end

service 'logstash-forwarder' do
  supports :status => true, :restart => true
end

template "/etc/logstash-forwarder.conf" do
  source "logstash-forwarder.conf.erb"
  owner  "root"
  group  "root"
  mode   "0644"
  notifies :restart, 'service[logstash-forwarder]', :immediately
end
