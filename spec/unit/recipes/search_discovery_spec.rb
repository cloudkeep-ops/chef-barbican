require 'spec_helper'

describe 'barbican::search_discovery' do
  let(:chef_run) do
    @chef_run = ::ChefSpec::Runner.new
    @chef_run.converge(described_recipe)
  end

  it 'queue search sets rabbit hosts with sorted list' do

    queue_one = stub_node('queue-one') do |node|
      node.automatic['ipaddress'] = '192.168.1.40'
      node.set['node_group']['tag'] = 'queue'
    end

    queue_two = stub_node('queue-two') do |node|
      node.automatic['ipaddress'] = '192.168.1.30'
      node.set['node_group']['tag'] = 'queue'
    end

    [queue_one, queue_two].each { |postgres_node| ChefSpec::Server.create_node(postgres_node) }

    chef_run.node.set['barbican']['discovery']['enable_queue_search'] = true
    chef_run.node.set['barbican']['discovery']['queue_search_query'] = 'node_group_tag:queue'
    chef_run.converge(described_recipe)
    expect(chef_run.node['barbican']['queue']['rabbit_hosts']).to eq [
      "#{queue_two['ipaddress']}:#{chef_run.node['barbican']['queue']['rabbit_port']}",
      "#{queue_one['ipaddress']}:#{chef_run.node['barbican']['queue']['rabbit_port']}"
    ]
  end

  it 'queue uses default value when search disabled' do

    chef_run.node.set['barbican']['discovery']['enable_queue_search'] = false
    chef_run.node.set['barbican']['discovery']['queue_search_query'] = 'node_group_tag:queue'
    chef_run.converge(described_recipe)
    expect(chef_run.node['barbican']['queue']['rabbit_hosts']).to eq chef_run.node.default['barbican']['queue']['rabbit_hosts']
  end

  it 'db search returns master postgres node' do

    postgres_master = stub_node('postgres-master') do |node|
      node.automatic['ipaddress'] = '192.168.1.40'
      node.set['node_group']['tag'] = 'database'
      node.set['postgresql']['replication']['node_type'] = 'master'
    end

    postgres_slave = stub_node('postgres-slave') do |node|
      node.automatic['ipaddress'] = '192.168.1.40'
      node.set['node_group']['tag'] = 'database'
      node.set['postgresql']['replication']['node_type'] = 'slave'
    end

    [postgres_master, postgres_slave].each { |postgres_node| ChefSpec::Server.create_node(postgres_node) }

    chef_run.node.set['barbican']['discovery']['enable_db_search'] = true
    chef_run.node.set['barbican']['discovery']['db_search_query'] = 'node_group_tag:database AND postgresql_replication_node_type:master'
    chef_run.converge(described_recipe)
    expect(chef_run.node['barbican']['db_ip']).to eq postgres_master['ipaddress']
  end

  it 'db uses default value when search disabled' do

    chef_run.node.set['barbican']['discovery']['enable_db_search'] = false
    chef_run.node.set['barbican']['discovery']['db_search_query'] = 'node_group_tag:database AND postgresql_replication_node_type:master'
    chef_run.converge(described_recipe)
    expect(chef_run.node['barbican']['db_ip']).to eq chef_run.node.default['barbican']['db_ip']
  end

end
