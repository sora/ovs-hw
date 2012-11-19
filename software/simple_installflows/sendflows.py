#!/usr/bin/env python

import socket, struct, time, popen2, re

host = '127.0.0.1'
port = 3776
addr = (host, port)
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

cmd = ('cat dump-flows.log')

p = re.compile(r'priority=(\d+),in_port=(\d+) actions=output:(\d+)')
while True:
  out, stdin, err = popen2.popen3(cmd)
  for line in out:
    m = p.search(line[:-1])
    if m:
      msg_body = struct.pack('>bb', int(m.group(2)), int(m.group(3)))
      s.sendto(msg_body, addr)
      print(struct.unpack('>bb', msg_body))
  time.sleep(5)

# NXST_FLOW reply (xid=0x4):
#  cookie=0x0, duration=677.201s, table=0, n_packets=0, n_bytes=0, idle_age=677, priority=0 actions=NORMAL
#  cookie=0x0, duration=129.448s, table=0, n_packets=0, n_bytes=0, idle_age=129, priority=103,in_port=0 actions=output:3
#  cookie=0x0, duration=133.691s, table=0, n_packets=0, n_bytes=0, idle_age=133, priority=102,in_port=0 actions=output:2
#  cookie=0x0, duration=172.228s, table=0, n_packets=0, n_bytes=0, idle_age=172, priority=101,in_port=0 actions=output:1
#  cookie=0x0, duration=104.973s, table=0, n_packets=0, n_bytes=0, idle_age=104, priority=106,in_port=3 actions=output:0
#  cookie=0x0, duration=110.59s, table=0, n_packets=0, n_bytes=0, idle_age=110, priority=105,in_port=2 actions=output:0
#  cookie=0x0, duration=117.829s, table=0, n_packets=0, n_bytes=0, idle_age=117, priority=104,in_port=1 actions=output:0
