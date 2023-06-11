#!/bin/python3
from socket import *
from scapy.all import Ether, Raw, Dot3, LLC, STP, get_if_hwaddr, get_if_list, sendp


h2_addr = "08:00:00:00:00:22"
sp_addr = "01:80:C2:00:00:00"


def get_if():
  ifs=get_if_list()
  iface=None # "h1-eth0"
  for i in get_if_list():
      if "eth0" in i:
          iface=i
          break;
  if not iface:
      print("Cannot find eth0 interface")
      exit(1)
  return iface

def main():
  iface = get_if()
  addr = get_if_hwaddr(iface)
  print("Sent Ethernet packet on eth0")
  print("Address:", addr)
  print("hello - send hello msg")
  print("nbpdu - send BPDU frame")
  print("bbpdu - send better BPDU frame")
  

  while True:
    cmd = input()
    if cmd == "nbpdu":
      pkt = Dot3(src=addr, dst=sp_addr) / LLC() / STP(rootid=10)

    elif cmd == "hello":
      pkt = Ether(src=addr, dst=h2_addr) / Raw(load=b'\x1C')

    elif cmd == "bbpdu":
      pkt = Dot3(src=addr, dst=sp_addr) / LLC() / STP(rootid=5)

    else:
       print("Unknown command")
       continue
    
    pkt.show()
    sendp(pkt, iface=iface, verbose=False)
    


if __name__ == '__main__':
    main()

  