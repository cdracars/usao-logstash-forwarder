#
# Cookbook Name:: usao-logstash-forwarder
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

execute "Move SSL Certs" do
  scp /etc/pki/tls/certs/logstash-forwarder.crt node['usao-logstash-forwarder']['server']['user']@node['usao-logstash-forwarder']['server']:/tmp
end

apt_repository 'logstashforwarder' do
  uri 'http://packages.elasticsearch.org/logstashforwarder/debian'
  components ['main']
  distribution 'stable'
  key 'C8068B11'
  keyserver 'packages.elasticsearch.org/GPG-KEY-elasticsearch'
  action :add
  deb_src true
end

echo 'deb http://packages.elasticsearch.org/logstashforwarder/debian stable main' | sudo tee /etc/apt/sources.list.d/logstashforwarder.list

wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -

sudo apt-get update
sudo apt-get install logstash-forwarder

sudo mkdir -p /etc/pki/tls/certs
sudo cp /tmp/logstash-forwarder.crt

sudo vi /etc/logstash-forwarder.conf

    "servers": [ "logstash_server_private_IP:5000" ],
    "timeout": 15,
    "ssl ca": "/etc/pki/tls/certs/logstash-forwarder.crt"

    {
      "paths": [
        "/var/log/syslog",
        "/var/log/auth.log"
       ],
      "fields": { "type": "syslog" }
    }

sudo service logstash-forwarder restart
