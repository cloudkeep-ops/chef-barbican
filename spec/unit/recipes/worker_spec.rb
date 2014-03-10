require 'spec_helper'

describe 'barbican::worker' do

  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'node group tag set to worker' do
    expect(chef_run.node['node_group']['tag']).to eq 'barbican_worker'
  end

  it 'includes default recipe' do
    expect(chef_run).to include_recipe('barbican::default')
  end

  it 'installs latest barbican-common package' do
    expect(chef_run).to install_package(chef_run.node['barbican']['common_package']).with(
      :action => [:install],
      :retries => 5,
      :retry_delay => 10
    )
  end

  it 'installs latest barbican-common package without version' do
    expect(chef_run).to_not install_package(chef_run.node['barbican']['common_package']).with(
      :version => chef_run.node['barbican']['version']
    )
  end

  it 'installs specific version of barbican-common package' do
    chef_run.node.set['barbican']['pin_version'] = true
    chef_run.converge(described_recipe)
    expect(chef_run).to install_package(chef_run.node['barbican']['common_package']).with(
      :action => [:install],
      :retries => 5,
      :retry_delay => 10,
      :version => chef_run.node['barbican']['version']
    )
  end

  it 'barbican-common install notifies restart of service[barbican-worker]' do
    resource = chef_run.package(chef_run.node['barbican']['common_package'])
    expect(resource).to notify('service[barbican-worker]').to(:restart).delayed
  end

  it 'installs latest barbican-worker package' do
    expect(chef_run).to install_package(chef_run.node['barbican']['worker_package']).with(
      :action => [:install],
      :retries => 5,
      :retry_delay => 10
    )
  end

  it 'installs latest barbican-worker package without version' do
    expect(chef_run).to_not install_package(chef_run.node['barbican']['worker_package']).with(
      :version => chef_run.node['barbican']['version']
    )
  end

  it 'installs specific version of barbican-worker package' do
    chef_run.node.set['barbican']['pin_version'] = true
    chef_run.converge(described_recipe)
    expect(chef_run).to install_package(chef_run.node['barbican']['worker_package']).with(
      :action => [:install],
      :retries => 5,
      :retry_delay => 10,
      :version => chef_run.node['barbican']['version']
    )
  end

  it 'barbican-worker install notifies restart of service[barbican-worker]' do
    resource = chef_run.package(chef_run.node['barbican']['worker_package'])
    expect(resource).to notify('service[barbican-worker]').to(:restart).delayed
  end

  it 'creates barbican-api.conf with sql-lite connection' do
    expect(chef_run).to create_template('/etc/barbican/barbican-api.conf').with(
      :source => 'barbican.conf.erb',
      :owner => 'barbican',
      :group => 'barbican',
      :variables => {
        :bind_host => chef_run.node['barbican']['api']['bind_host'],
        :bind_port => chef_run.node['barbican']['api']['port'],
        :host_ref => chef_run.node['barbican']['api']['host_ref'],
        :log_file => chef_run.node['barbican']['worker']['log_file'],
        :connection => chef_run.node['barbican']['sqlite_connection']
      }
    )
    expect(chef_run).to render_file('/etc/barbican/barbican-api.conf')
  end

  it 'creates barbican-api.conf with postgres connection and default user' do
    db_user = chef_run.node['barbican']['db_user']
    db_pass = chef_run.node['barbican']['db_user']
    chef_run.node.set['barbican']['use_postgres'] = true
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template('/etc/barbican/barbican-api.conf').with(
      :source => 'barbican.conf.erb',
      :owner => 'barbican',
      :group => 'barbican',
      :variables => {
        :bind_host => chef_run.node['barbican']['api']['bind_host'],
        :bind_port => chef_run.node['barbican']['api']['port'],
        :host_ref => chef_run.node['barbican']['api']['host_ref'],
        :log_file => chef_run.node['barbican']['worker']['log_file'],
        :connection => "postgresql+psycopg2://#{db_user}:#{db_pass}@#{chef_run.node['barbican']['db_ip']}:5432/#{chef_run.node['barbican']['db_name']}"
      }
    )
    expect(chef_run).to render_file('/etc/barbican/barbican-api.conf')
  end

  it 'creates barbican-api.conf with postgres connection with databage values' do
    db_user = chef_run.node['barbican']['db_user']
    db_pass = 'spec_pass'
    ChefSpec::Server.create_data_bag('barbican',
      'postgresql' => {
        'password' => {
          'barbican' => 'spec_pass'
        }
      }
    )
    chef_run.node.set['barbican']['postgres']['databag_name'] = 'barbican'
    chef_run.node.set['barbican']['use_postgres'] = true
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template('/etc/barbican/barbican-api.conf').with(
      :source => 'barbican.conf.erb',
      :owner => 'barbican',
      :group => 'barbican',
      :variables => {
        :bind_host => chef_run.node['barbican']['api']['bind_host'],
        :bind_port => chef_run.node['barbican']['api']['port'],
        :host_ref => chef_run.node['barbican']['api']['host_ref'],
        :log_file => chef_run.node['barbican']['worker']['log_file'],
        :connection => "postgresql+psycopg2://#{db_user}:#{db_pass}@#{chef_run.node['barbican']['db_ip']}:5432/#{chef_run.node['barbican']['db_name']}"
      }
    )
    expect(chef_run).to render_file('/etc/barbican/barbican-api.conf')
  end

  it 'barbican-api.conf notifies restart of service[barbican-worker]' do
    resource = chef_run.template('/etc/barbican/barbican-api.conf')
    expect(resource).to notify('service[barbican-worker]').to(:restart).delayed
  end

  it 'barbican service is enabled and started' do
    expect(chef_run).to enable_service('barbican-worker').with(
      :supports => {
        :status => true, :restart => true, :reload => true
        },
      :action => [:enable, :start]
    )
    expect(chef_run).to start_service('barbican-worker').with(
      :supports => {
        :status => true, :restart => true, :reload => true
        },
      :action => [:enable, :start]
    )
  end

end
