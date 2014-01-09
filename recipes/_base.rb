#
# Cookbook Name:: barbican
# Recipe:: _base
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

include_recipe 'yum'
include_recipe 'yum-epel'
unless Chef::Config[:solo]
    include_recipe 'authorized_keys'
end
include_recipe 'ntp'

#TODO(reaperhulk): switch to TLS when we drop a cert on that repo
yum_repository 'barbican' do
  description 'Barbican CentOS-$releasever - local packages for $basearch'
  baseurl 'http://yum-repo.cloudkeep.io/centos/$releasever/barbican/$basearch'
  enabled true
  gpgcheck false
  gpgkey 'http://yum-repo.cloudkeep.io/gpg'
  action :create
end

# Configure base New Relic monitoring.
unless Chef::Config[:solo]
  newrelic_info = data_bag_item(node.chef_environment, :newrelic)
  node.set[:newrelic] = node[:newrelic].merge(newrelic_info)
  node.save

  include_recipe 'barbican::_newrelic'
end
