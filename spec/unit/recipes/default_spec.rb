require 'spec_helper'

describe 'barbican::default' do
  
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }
  
  # barbican repo created
  it "creates yum repository barbican" do                                             
    expect(chef_run).to create_yum_repository('barbican').with(
      description: 'Barbican CentOS-$releasever - local packages for $basearch',
      baseurl: chef_run.node['barbican']['yum_repo']['baseurl'],
      enabled: true,
      gpgcheck: chef_run.node['barbican']['yum_repo']['gpgcheck'],
      gpgkey: chef_run.node['barbican']['yum_repo']['gpgkey'],
      action: [:create]
    )
    
  end 

  # test that by defualt postgres drivers are not installed
  it 'does not install python-psycopg2' do
    expect(chef_run).to_not install_package('python-psycopg2')
  end  

  # if use_postgres then postgres drivers are installed
  it 'does install python-psycopg2' do
    chef_run.node.set['barbican']['use_postgres'] = true
    chef_run.converge(described_recipe)
    expect(chef_run).to install_package('python-psycopg2').with(action: [:install])
  end

  # uses default queue values of databag not specified
  it 'uses default queue attrs' do
    expect(chef_run.node['barbican']['queue']['rabbit_userid']).to eq 'guest'
    expect(chef_run.node['barbican']['queue']['rabbit_password']).to eq 'guest'
    expect(chef_run.node['barbican']['queue']['rabbit_virtual_host']).to eq '/barbican'
  end  

  it 'uses databag queue attrs' do
    ChefSpec::Server.create_data_bag('barbican', {
      'rabbitmq' => {
        'username' => 'barbican',
        'password' => 'barbican',
        'vhost' => '/barbican_vhost'
      }
    })
    chef_run.node.set['barbican']['queue']['databag_name'] = 'barbican'
    chef_run.converge(described_recipe)
    expect(chef_run.node['barbican']['queue']['rabbit_userid']).to eq 'barbican'
    expect(chef_run.node['barbican']['queue']['rabbit_password']).to eq 'barbican'
    expect(chef_run.node['barbican']['queue']['rabbit_virtual_host']).to eq '/barbican_vhost'
  end

end
