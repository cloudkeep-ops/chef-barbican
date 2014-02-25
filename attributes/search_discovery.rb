default['barbican']['discovery']['enable_queue_search'] = false
default['barbican']['discovery']['queue_search_query'] = "node_group_tag:queue AND chef_environment:#{node.chef_environment}"
default['barbican']['discovery']['queue_ip_attribute'] = 'ipaddress'

default['barbican']['discovery']['enable_db_search'] = false
default['barbican']['discovery']['db_search_query'] = "node_group_tag:database AND chef_environment:#{node.chef_environment}"
default['barbican']['discovery']['db_ip_attribute'] = 'ipaddress'
