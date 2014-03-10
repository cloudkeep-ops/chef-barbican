[Chef::Recipe, Chef::Resource].each { |l| l.send :include, ::Extensions }

unless Chef::Config[:solo]

  if node['barbican']['discovery']['enable_queue_search']
    rabbit_hosts = []
    q_nodes = search(:node, node['barbican']['discovery']['queue_search_query'])

    q_nodes.each do |q_node|
      q_ip = select_ip_attribute(q_node, node['barbican']['discovery']['queue_ip_attribute'])
      rabbit_hosts.push("#{q_ip}:#{node['barbican']['queue']['rabbit_port']}")
    end

    if q_nodes.empty?
      Chef::Log.info 'No queue nodes discovered, using default values'
    else
      node.set['barbican']['queue']['rabbit_hosts'] = rabbit_hosts.sort
    end
  end

  if node['barbican']['discovery']['enable_db_search']
    db_nodes = search(:node, node['barbican']['discovery']['db_search_query'])
    if db_nodes.empty?
      Chef::Log.info 'No database nodes found, using sqlite backend instead.'
    else
      db_node = db_nodes[0]
      node.set['barbican']['db_ip'] = select_ip_attribute(db_node, node['barbican']['discovery']['db_ip_attribute'])
    end
  end

end
