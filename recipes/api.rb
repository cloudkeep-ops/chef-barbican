#
# Cookbook Name:: barbican
# Recipe:: api
#
# Copyright (C) 2013 Rackspace, Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Note that the yum repository configuration used here was found at this site:
#   http://docs.opscode.com/resource_cookbook_file.html
#

node.set['node_group']['tag'] = 'barbican_api'

include_recipe 'barbican'

# install packages for barbican api
[node['barbican']['common_package'], node['barbican']['api_package']] .each do |pkg|
  package pkg do
    action :install
    retries 5
    retry_delay 10
    version node['barbican']['version'] if node['barbican']['use_version']
  end
end

# default to sql lite connection
connection = node['barbican']['sqlite_connection']

# if attribute is set, use postgres
if node['barbican']['use_postgres']
  db_user = node['barbican']['db_user']
  db_pw = node['barbican']['db_password']

  #if a databag name is provided, pull password from datbag
  if node['barbican']['postgres']['databag_name']
    postgres_bag = data_bag_item(node['barbican']['postgres']['databag_name'], 'postgresql')
    db_pw = postgres_bag['password'][db_user]
  end 
  connection = "postgresql+psycopg2://#{db_user}:#{db_pw}@#{node[:barbican][:db_ip]}:5432/#{node[:barbican][:db_name]}"
end

# Create barbican conf files for api and admin services
%w{ api admin }.each do |barbican_service|
  template "/etc/barbican/barbican-#{barbican_service}.conf" do
    source "barbican.conf.erb"
    owner "barbican"
    group "barbican"
    variables({
      :bind_host => node['barbican'][barbican_service]['bind_host'],
      :bind_port => node['barbican'][barbican_service]['port'],
      :host_ref => node['barbican'][barbican_service]['host_ref'],
      :log_file => node['barbican'][barbican_service]['log_file'],
      :connection => connection
    })
  end
end

# create uwsgi.ini file for api and admin services
%w{ api admin }.each do |vassal|
  template "/etc/barbican/vassals/barbican-#{vassal}.ini" do
    source "uwsgi.ini.erb"
    owner "barbican"
    group "barbican"
    variables({
      :socket => node['barbican'][vassal]['uwsgi']['socket'],
      :protocol => node['barbican'][vassal]['uwsgi']['protocol'],
      :processes => node['barbican'][vassal]['uwsgi']['processes'],
      :lazy => node['barbican'][vassal]['uwsgi']['lazy'],
      :vacuum => node['barbican'][vassal]['uwsgi']['vacuum'],
      :no_default_app => node['barbican'][vassal]['uwsgi']['no_default_app'],
      :memory_report => node['barbican'][vassal]['uwsgi']['memory_report'],
      :plugins => node['barbican'][vassal]['uwsgi']['plugins'],
      :use_paste => node['barbican'][vassal]['uwsgi']['use_paste'],
      :paste => node['barbican'][vassal]['uwsgi']['paste'],
      :buffer_size => node['barbican'][vassal]['uwsgi']['buffer_size']
    })
  end
end

# Configure policy file
template "/etc/barbican/policy.json" do
  source "policy.json.erb"
  owner "barbican"
  group "barbican"
end

# Start the daemon
service "barbican-api" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
