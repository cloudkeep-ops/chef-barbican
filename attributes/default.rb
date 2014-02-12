# set tag to 'api' or 'worker'
default['node_group']['tag'] = 'barbican_api'

# setting use_version will pin the version number rather than installing the latest
default['barbican']['pin_version'] = false
default['barbican']['version'] = '2014.1.dev13.g788d1ea-1'
# repo and package settings
default['barbican']['yum_repo']['baseurl'] = 'http://yum-repo.cloudkeep.io/centos/$releasever/barbican/$basearch'
default['barbican']['yum_repo']['gpgcheck'] = false
default['barbican']['yum_repo']['gpgkey'] = 'http://yum-repo.cloudkeep.io/gpg'

default['barbican']['api_package'] = 'barbican-api'
default['barbican']['common_package'] = 'barbican-common'
default['barbican']['worker_package'] = 'barbican-worker'

# api specific settings
default['barbican']['api']['bind_host'] = '0.0.0.0'
default['barbican']['api']['port'] = '9311'
default['barbican']['api']['host_ref'] = "http://#{node['hostname']}:#{node['barbican']['api']['port']}"
default['barbican']['api']['log_file'] = '/var/log/barbican/barbican-api.log'

# admin configuration
default['barbican']['admin']['bind_host'] = '0.0.0.0'
default['barbican']['admin']['port'] = '9312'
default['barbican']['admin']['host_ref'] = "http://#{node['hostname']}:#{node['barbican']['admin']['port']}"
default['barbican']['admin']['log_file'] = '/var/log/barbican/barbican-admin.log'

# worker configurations
default['barbican']['worker']['log_file'] = '/var/log/barbican/barbican-worker.log'

# logging settings
default['barbican']['logging']['verbose'] = true
default['barbican']['logging']['debug'] = true
default['barbican']['logging']['use_log_file'] = true
default['barbican']['logging']['use_syslog'] = false
default['barbican']['logging']['syslog_log_facility'] = 'LOG_USER'

default['barbican']['backlog'] = 4096
default['barbican']['tcp_keepidle'] = 600

# database settings
default['barbican']['use_postgres'] = false
default['barbican']['postgres']['databag_name'] = nil

default['barbican']['db_name'] = 'barbican_api'
default['barbican']['db_user'] = 'barbican'
default['barbican']['db_password'] = 'barbican'

default['barbican']['db_ip'] = '127.0.0.1'
default['barbican']['sqlite_connection'] = 'sqlite:////var/lib/barbican/barbican.sqlite'
default['barbican']['sql_idle_timeout'] = 3600
default['barbican']['sql_max_retries'] = 60
default['barbican']['sql_retry_interval'] = 1
default['barbican']['db_auto_create'] = true
default['barbican']['max_limit_paging'] = 100
default['barbican']['default_limit_paging'] = 10

# api middleware context options
default['barbican']['owner_is_tenant'] = true
default['barbican']['admin_role'] = 'admin'
default['barbican']['allow_anonymous_access'] = false

# validator settings
default['barbican']['max_allowed_secret_in_bytes'] = 10000

#ssl settings
default['barbican']['enable_ssl'] = false
default['barbican']['cert_file'] = '/path/to/certfile'
default['barbican']['key_file'] = '/path/to/keyfile'
default['barbican']['ca_file'] = '/path/to/cafile'

# oslo.messaging 
default['barbican']['queue']['databag_name'] = nil
default['barbican']['queue']['ampq_durable_queues'] = true
default['barbican']['queue']['rabbit_userid'] = 'guest'
default['barbican']['queue']['rabbit_password'] = 'guest'
default['barbican']['queue']['rabbit_ha_queues'] = false
default['barbican']['queue']['rabbit_port'] = 5672
default['barbican']['queue']['rabbit_hosts'] = ["localhost:#{node['barbican']['queue']['rabbit_port']}"]
default['barbican']['queue']['rabbit_virtual_host'] = "/barbican"

# queue settings
default['barbican']['queue']['enable'] = false
default['barbican']['queue']['namespace'] = 'barbican'
default['barbican']['queue']['topic'] = 'barbican.workers'
default['barbican']['queue']['version'] = '1.1'
default['barbican']['queue']['server_name'] = 'barbican.queue'

# crypto settings
default['barbican']['crypto']['namespace'] = 'barbican.crypto.plugin'
default['barbican']['crypto']['enabled_crypto_plugins'] = ['simple_crypto']

#simple crypto plugin settings
default['barbican']['simple_crypto_plugin']['kek'] = 'sixteen_byte_key'

# PKCS11 crypto plugin settings
default['barbican']['p11_crypto_plugin']['library_path'] = '/usr/lib/libCryptoki2_64.so'
default['barbican']['p11_crypto_plugin']['login'] = 'password'

# openstack policy settings
default['barbican']['policy']['policy_file'] = '/etc/barbican/policy.json'
default['barbican']['policy']['admin_roles'] = ['admin']
default['barbican']['policy']['audit_roles'] = ['audit']
default['barbican']['policy']['creator_roles'] = ['creator']
default['barbican']['policy']['observer_roles'] = ['observer']

# api uwsgi settings
default['barbican']['api']['uwsgi']['socket'] = "#{node['barbican']['api']['bind_host']}:#{node['barbican']['api']['port']}"
default['barbican']['api']['uwsgi']['protocol'] = 'http'
default['barbican']['api']['uwsgi']['processes'] = 1
default['barbican']['api']['uwsgi']['lazy'] = true
default['barbican']['api']['uwsgi']['vacuum'] = true
default['barbican']['api']['uwsgi']['no_default_app'] = true
default['barbican']['api']['uwsgi']['memory_report'] = true
default['barbican']['api']['uwsgi']['plugins'] = 'python'
default['barbican']['api']['uwsgi']['use_paste'] = true
default['barbican']['api']['uwsgi']['paste'] = 'config:/etc/barbican/barbican-api-paste.ini'
default['barbican']['api']['uwsgi']['buffer_size'] = 32768

# admin uwsgi settings
default['barbican']['admin']['uwsgi']['socket'] = "#{node['barbican']['admin']['bind_host']}:#{node['barbican']['admin']['port']}"
default['barbican']['admin']['uwsgi']['protocol'] = 'http'
default['barbican']['admin']['uwsgi']['processes'] = 1
default['barbican']['admin']['uwsgi']['lazy'] = true
default['barbican']['admin']['uwsgi']['vacuum'] = true
default['barbican']['admin']['uwsgi']['no_default_app'] = true
default['barbican']['admin']['uwsgi']['memory_report'] = true
default['barbican']['admin']['uwsgi']['plugins'] = 'python'
default['barbican']['admin']['uwsgi']['use_paste'] = true
default['barbican']['admin']['uwsgi']['paste'] = 'config:/etc/barbican/barbican-api-paste.ini'
default['barbican']['admin']['uwsgi']['buffer_size'] = 32768
