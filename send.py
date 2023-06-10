#!/bin/python3
from socket import *

h1_addr = "\x08\x00\x00\x00\x01\x11"
h2_addr = "\x08\x00\x00\x00\x02\x22"
sp_addr = "\x01\x80\xC2\x00\x00\x00"


def sendeth(src, dst, eth_type, payload, interface = "eth0"):
  assert(len(eth_type) == 2) # 16-bit ethernet type
  s = socket(AF_PACKET, SOCK_RAW)
  s.bind((interface, 0))
  return s.send((dst + src + eth_type + payload).encode())

def send_hello():
  sendeth(h1_addr, h2_addr, "\x00\x05", "hello")

def send_nbpdu():
  sendeth(h1_addr, sp_addr, "\x00\x05", "hello")

if __name__ == "__main__":
  print("Sent Ethernet packet on eth0")
  print("hello - send hello msg")
  print("nbpdu - send BPDU frame")

  while True :
    cmd = input()

    if cmd == "hello":
        send_hello()
    elif cmd == "nbpdu":
      send_nbpdu()
  