name             'barbican'
maintainer       'Rackspace, Inc.'
maintainer_email 'cloudkeep@googlegroups.com'
license          'Apache 2.0'
description      'Installs/Configures barbican'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.7'

depends          'yum'
depends          'yum-epel'
depends          'authorized_keys'
depends          'ntp'
depends          'barbican-cloudpassage'
depends          'newrelic'
depends          'python'

