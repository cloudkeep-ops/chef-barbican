#
# Cookbook Name:: barbican
# Recipe:: worker
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

node.set['node_group']['tag'] = 'barbican_worker'

include_recipe 'barbican'

[node['barbican']['common_package'], node['barbican']['worker_package']] .each do |pkg|
  package pkg do
    action :install
    retries 5
    retry_delay 10
    version node['barbican']['version'] if node['barbican']['pin_version']
    notifies :restart, 'service[barbican-worker]'
  end
end

connection = node['barbican']['sqlite_connection']

# if attribute is set, use postgres
if node['barbican']['use_postgres']
  db_user = node['barbican']['db_user']
  db_pw = node['barbican']['db_password']

  # if a databag name is provided, pull password from datbag
  if node['barbican']['postgres']['databag_name']
    postgres_bag = data_bag_item(node['barbican']['postgres']['databag_name'], 'postgresql')
    db_pw = postgres_bag['password'][db_user]
  end
  connection = "postgresql+psycopg2://#{db_user}:#{db_pw}@#{node['barbican']['db_ip']}:5432/#{node['barbican']['db_name']}"
end

# Configure based on external dependencies.
template '/etc/barbican/barbican-api.conf' do
  source 'barbican.conf.erb'
  owner 'barbican'
  group 'barbican'
  variables(
    :bind_host => node['barbican']['api']['bind_host'],
    :bind_port => node['barbican']['api']['port'],
    :host_ref => node['barbican']['api']['host_ref'],
    :log_file => node['barbican']['worker']['log_file'],
    :connection => connection
  )
  notifies :restart, 'service[barbican-worker]'
end

# Start the daemon
service 'barbican-worker' do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end
