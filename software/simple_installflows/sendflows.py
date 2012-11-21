#!/usr/bin/env python

import sys, socket, struct, time, popen2, re

MAGIC = struct.pack('>BBBB', 0xC0, 0xC0, 0xC0, 0xCC)

argvs = sys.argv

addr = '192.168.0.1'
port = 3776
host = (addr, port)
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

cmd = ('cat ' + argvs[1])

p = re.compile(r'priority=(\d+),in_port=(\d+) actions=output:(\d+)')
while True:
  stdout, stdin, stderr = popen2.popen3(cmd)
  flows                 = [0] * 4
  cnt                   = 1
  for line in stdout:
    m = p.search(line[:-1])
    if m:
      print "Flow %d. (in_port: %s, output: %s)" % (cnt, m.group(2), m.group(3))
      cnt           = cnt + 1
      inport        = int(m.group(2))
      output        = int(m.group(3))
      flows[inport] = flows[inport] | (1 << output)
  msg = MAGIC + struct.pack('>bbbb', flows[0], flows[1] | (1 << 4), flows[2] | (2 << 4), flows[3] | (3 << 4))
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
