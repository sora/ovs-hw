#!/usr/bin/env python

import socket, struct, time, popen2, re

MAX_NFLOWS = 10

addr = '203.178.143.1'
port = 3776
host = (addr, port)
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

cmd = ('cat sample_dump-flows.txt')

p = re.compile(r'priority=(\d+),in_port=(\d+) actions=output:(\d+)')
while True:
  flows                 = list()
  cnt                   = MAX_NFLOWS
  stdout, stdin, stderr = popen2.popen3(cmd)
  for line in stdout:
    m = p.search(line[:-1])
    if m:
      print "dump_flows (in_port: %s, output: %s)" % (m.group(2), m.group(3))
      flows.append(struct.pack('>bb', int(m.group(2)), int(m.group(3))))
      cnt = cnt - 1
  while cnt > 0:
    flows.append(struct.pack('>bb', 0, 0))
    cnt = cnt - 1
  msg = ''.join([str(t) for t in flows])
  s.sendto(msg, host)
  print "*--- --- --- --- --- --- --- ---*"
  time.sleep(3)

# NXST_FLOW reply (xid=0x4):
#  cookie=0x0, duration=677.201s, table=0, n_packets=0, n_bytes=0, idle_age=677, priority=0 actions=NORMAL
#  cookie=0x0, duration=129.448s, table=0, n_packets=0, n_bytes=0, idle_age=129, priority=103,in_port=0 actions=output:3
#  cookie=0x0, duration=133.691s, table=0, n_packets=0, n_bytes=0, idle_age=133, priority=102,in_port=0 actions=output:2
#  cookie=0x0, duration=172.228s, table=0, n_packets=0, n_bytes=0, idle_age=172, priority=101,in_port=0 actions=output:1
#  cookie=0x0, duration=104.973s, table=0, n_packets=0, n_bytes=0, idle_age=104, priority=106,in_port=3 actions=output:0
#  cookie=0x0, duration=110.59s, table=0, n_packets=0, n_bytes=0, idle_age=110, priority=105,in_port=2 actions=output:0
#  cookie=0x0, duration=117.829s, table=0, n_packets=0, n_bytes=0, idle_age=117, priority=104,in_port=1 actions=output:0
