ovs-ofctl del-flows br0 'in_port=0'
ovs-ofctl del-flows br0 'in_port=1'
ovs-ofctl del-flows br0 'in_port=2'

#ovs-ofctl add-flow br0 'in_port=0, priority=101, actions=output:1'
ovs-ofctl add-flow br0 'in_port=0, priority=102, actions=output:2'
#ovs-ofctl add-flow br0 'in_port=1, priority=103, actions=output:0'
ovs-ofctl add-flow br0 'in_port=1, priority=104, actions=output:2'
ovs-ofctl add-flow br0 'in_port=2, priority=105, actions=output:0'
ovs-ofctl add-flow br0 'in_port=2, priority=106, actions=output:1'

ovs-ofctl dump-flows br0

