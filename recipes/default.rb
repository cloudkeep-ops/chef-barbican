#
# Cookbook Name:: barbican
# Recipe:: default
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

yum_repository "RDO-#{node['openstack']['release']}" do
  description "OpenStack RDO repo for #{node['openstack']['release']}"
  baseurl node['openstack']['yum']['uri']
  enabled true
  gpgkey node['openstack']['yum']['repo-key']
  action :create
end

# TODO(reaperhulk): switch to TLS when we drop a cert on that repo
yum_repository 'barbican' do
  description 'Barbican CentOS-$releasever - local packages for $basearch'
  baseurl node['barbican']['yum_repo']['baseurl']
  enabled true
  gpgcheck node['barbican']['yum_repo']['gpgcheck']
  gpgkey node['barbican']['yum_repo']['gpgkey']
  http_caching node['barbican']['yum_repo']['http_caching']
  metadata_expire node['barbican']['yum_repo']['metadata_expire']
  action :create
end

#TODO(dmend): Use EPEL package if this bug is ever fixed
# https://bugzilla.redhat.com/show_bug.cgi?id=814598
package 'python-uwsgi'

#TODO(dmend): Use RDO package if they pick this one up
%w{ libffi-devel python-devel openssl-devel }.each do |pkg|
  package pkg
end
python_pip "cryptography"

package 'python-psycopg2' do
  only_if { node['barbican']['use_postgres'] }
  action :install
end

if node['barbican']['queue']['databag_name']
  rabbitmq_bag = data_bag_item(node['barbican']['queue']['databag_name'], 'rabbitmq')
  node.set['barbican']['queue']['rabbit_userid'] = rabbitmq_bag['username']
  node.set['barbican']['queue']['rabbit_password'] = rabbitmq_bag['password']
  node.set['barbican']['queue']['rabbit_virtual_host'] = rabbitmq_bag['vhost']
end
