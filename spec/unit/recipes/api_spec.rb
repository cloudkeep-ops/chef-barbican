require 'spec_helper'

describe 'barbican::api' do

  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'node group tag set to api' do
    expect(chef_run.node['node_group']['tag']).to eq 'barbican_api'
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

  it 'barbican-common install notifies restart of service[barbican-api]' do
    resource = chef_run.package(chef_run.node['barbican']['common_package'])
    expect(resource).to notify('service[barbican-api]').to(:restart).delayed
  end

  it 'installs latest barbican-api package' do
    expect(chef_run).to install_package(chef_run.node['barbican']['api_package']).with(
      :action => [:install],
      :retries => 5,
      :retry_delay => 10
    )
  end

  it 'installs latest barbican-api package without version' do
    expect(chef_run).to_not install_package(chef_run.node['barbican']['api_package']).with(
      :version => chef_run.node['barbican']['version']
    )
  end

  it 'installs specific version of barbican-api package' do
    chef_run.node.set['barbican']['pin_version'] = true
    chef_run.converge(described_recipe)
    expect(chef_run).to install_package(chef_run.node['barbican']['api_package']).with(
      :action => [:install],
      :retries => 5,
      :retry_delay => 10,
      :version => chef_run.node['barbican']['version']
    )
  end

  it 'barbican-api install notifies restart of service[barbican-api]' do
    resource = chef_run.package(chef_run.node['barbican']['api_package'])
    expect(resource).to notify('service[barbican-api]').to(:restart).delayed
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
        :log_file => chef_run.node['barbican']['api']['log_file'],
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
        :log_file => chef_run.node['barbican']['api']['log_file'],
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
        :log_file => chef_run.node['barbican']['api']['log_file'],
        :connection => "postgresql+psycopg2://#{db_user}:#{db_pass}@#{chef_run.node['barbican']['db_ip']}:5432/#{chef_run.node['barbican']['db_name']}"
      }
    )
    expect(chef_run).to render_file('/etc/barbican/barbican-api.conf')
  end

  it 'barbican-api.conf notifies restart of service[barbican-api]' do
    resource = chef_run.template('/etc/barbican/barbican-api.conf')
    expect(resource).to notify('service[barbican-api]').to(:restart).delayed
  end

  it 'creates barbican-admin.conf with sql-lite connection' do
    expect(chef_run).to create_template('/etc/barbican/barbican-admin.conf').with(
      :source => 'barbican.conf.erb',
      :owner => 'barbican',
      :group => 'barbican',
      :variables => {
        :bind_host => chef_run.node['barbican']['admin']['bind_host'],
        :bind_port => chef_run.node['barbican']['admin']['port'],
        :host_ref => chef_run.node['barbican']['admin']['host_ref'],
        :log_file => chef_run.node['barbican']['admin']['log_file'],
        :connection => chef_run.node['barbican']['sqlite_connection']
      }
    )
    expect(chef_run).to render_file('/etc/barbican/barbican-admin.conf')
  end

  it 'creates barbican-admin.conf with postgres connection and default user' do
    db_user = chef_run.node['barbican']['db_user']
    db_pass = chef_run.node['barbican']['db_user']
    chef_run.node.set['barbican']['use_postgres'] = true
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template('/etc/barbican/barbican-admin.conf').with(
      :source => 'barbican.conf.erb',
      :owner => 'barbican',
      :group => 'barbican',
      :variables => {
        :bind_host => chef_run.node['barbican']['admin']['bind_host'],
        :bind_port => chef_run.node['barbican']['admin']['port'],
        :host_ref => chef_run.node['barbican']['admin']['host_ref'],
        :log_file => chef_run.node['barbican']['admin']['log_file'],
        :connection => "postgresql+psycopg2://#{db_user}:#{db_pass}@#{chef_run.node['barbican']['db_ip']}:5432/#{chef_run.node['barbican']['db_name']}"
      }
    )
    expect(chef_run).to render_file('/etc/barbican/barbican-admin.conf')
  end

  it 'creates barbican-admin.conf with postgres connection with databage values' do
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
    expect(chef_run).to create_template('/etc/barbican/barbican-admin.conf').with(
      :source => 'barbican.conf.erb',
      :owner => 'barbican',
      :group => 'barbican',
      :variables => {
        :bind_host => chef_run.node['barbican']['admin']['bind_host'],
        :bind_port => chef_run.node['barbican']['admin']['port'],
        :host_ref => chef_run.node['barbican']['admin']['host_ref'],
        :log_file => chef_run.node['barbican']['admin']['log_file'],
        :connection => "postgresql+psycopg2://#{db_user}:#{db_pass}@#{chef_run.node['barbican']['db_ip']}:5432/#{chef_run.node['barbican']['db_name']}"
      }
    )
    expect(chef_run).to render_file('/etc/barbican/barbican-admin.conf')
  end

  it 'barbican-admin.conf notifies restart of service[barbican-api]' do
    resource = chef_run.template('/etc/barbican/barbican-admin.conf')
    expect(resource).to notify('service[barbican-api]').to(:restart).delayed
  end

  it 'barbican-api-paste.ini created' do
    expect(chef_run).to create_template('/etc/barbican/barbican-api-paste.ini').with(
      :source => 'barbican-paste.ini.erb',
      :owner => 'barbican',
      :group => 'barbican'
    )
    expect(chef_run).to render_file('/etc/barbican/barbican-api-paste.ini')
  end

  it 'barbican-api-paste.ini notifies restart of service[barbican-api]' do
    resource = chef_run.template('/etc/barbican/barbican-api-paste.ini')
    expect(resource).to notify('service[barbican-api]').to(:restart).delayed
  end

  it 'barbican-admin-paste.ini created' do
    expect(chef_run).to create_template('/etc/barbican/barbican-admin-paste.ini').with(
      :source => 'barbican-paste.ini.erb',
      :owner => 'barbican',
      :group => 'barbican'
    )
    expect(chef_run).to render_file('/etc/barbican/barbican-admin-paste.ini')
  end

  it 'barbican-admin-paste.ini notifies restart of service[barbican-api]' do
    resource = chef_run.template('/etc/barbican/barbican-admin-paste.ini')
    expect(resource).to notify('service[barbican-api]').to(:restart).delayed
  end

  it 'creates barbican-api.ini' do
    expect(chef_run).to create_template('/etc/barbican/vassals/barbican-api.ini').with(
      :source => 'uwsgi.ini.erb',
      :owner => 'barbican',
      :group => 'barbican',
      :variables => {
        :socket => chef_run.node['barbican']['api']['uwsgi']['socket'],
        :protocol => chef_run.node['barbican']['api']['uwsgi']['protocol'],
        :processes => chef_run.node['barbican']['api']['uwsgi']['processes'],
        :lazy => chef_run.node['barbican']['api']['uwsgi']['lazy'],
        :vacuum => chef_run.node['barbican']['api']['uwsgi']['vacuum'],
        :no_default_app => chef_run.node['barbican']['api']['uwsgi']['no_default_app'],
        :memory_report => chef_run.node['barbican']['api']['uwsgi']['memory_report'],
        :plugins => chef_run.node['barbican']['api']['uwsgi']['plugins'],
        :use_paste => chef_run.node['barbican']['api']['uwsgi']['use_paste'],
        :paste => chef_run.node['barbican']['api']['uwsgi']['paste'],
        :buffer_size => chef_run.node['barbican']['api']['uwsgi']['buffer_size'],
        :uid => chef_run.node['barbican']['api']['uwsgi']['uid'],
        :gid => chef_run.node['barbican']['api']['uwsgi']['gid']
      }
    )
    expect(chef_run).to render_file('/etc/barbican/vassals/barbican-api.ini')
  end

  it 'barbican-api.ini notifies restart of service[barbican-api]' do
    resource = chef_run.template('/etc/barbican/vassals/barbican-api.ini')
    expect(resource).to notify('service[barbican-api]').to(:restart).delayed
  end

  it 'creates barbican-admin.ini' do
    expect(chef_run).to create_template('/etc/barbican/vassals/barbican-admin.ini').with(
      :source => 'uwsgi.ini.erb',
      :owner => 'barbican',
      :group => 'barbican',
      :variables => {
        :socket => chef_run.node['barbican']['admin']['uwsgi']['socket'],
        :protocol => chef_run.node['barbican']['admin']['uwsgi']['protocol'],
        :processes => chef_run.node['barbican']['admin']['uwsgi']['processes'],
        :lazy => chef_run.node['barbican']['admin']['uwsgi']['lazy'],
        :vacuum => chef_run.node['barbican']['admin']['uwsgi']['vacuum'],
        :no_default_app => chef_run.node['barbican']['admin']['uwsgi']['no_default_app'],
        :memory_report => chef_run.node['barbican']['admin']['uwsgi']['memory_report'],
        :plugins => chef_run.node['barbican']['admin']['uwsgi']['plugins'],
        :use_paste => chef_run.node['barbican']['admin']['uwsgi']['use_paste'],
        :paste => chef_run.node['barbican']['admin']['uwsgi']['paste'],
        :buffer_size => chef_run.node['barbican']['admin']['uwsgi']['buffer_size'],
        :uid => chef_run.node['barbican']['admin']['uwsgi']['uid'],
        :gid => chef_run.node['barbican']['admin']['uwsgi']['gid']
      }
    )
    expect(chef_run).to render_file('/etc/barbican/vassals/barbican-admin.ini')
  end

  it 'barbican-admin.ini notifies restart of service[barbican-api]' do
    resource = chef_run.template('/etc/barbican/vassals/barbican-admin.ini')
    expect(resource).to notify('service[barbican-api]').to(:restart).delayed
  end

  it 'creates barbican policy json' do
    expect(chef_run).to create_template('/etc/barbican/policy.json').with(
      :source => 'policy.json.erb',
      :owner => 'barbican',
      :group => 'barbican'
    )
    expect(chef_run).to render_file('/etc/barbican/policy.json')
  end

  it 'policy.json notifies restart of service[barbican-api]' do
    resource = chef_run.template('/etc/barbican/policy.json')
    expect(resource).to notify('service[barbican-api]').to(:restart).delayed
  end

  it 'barbican service is enabled and started' do
    expect(chef_run).to enable_service('barbican-api').with(
      :supports => {
        :status => true, :restart => true, :reload => true
        },
      :action => [:enable, :start]
    )
    expect(chef_run).to start_service('barbican-api').with(
      :supports => {
        :status => true, :restart => true, :reload => true
        },
      :action => [:enable, :start]
    )
  end

end
