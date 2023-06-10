#!/bin/python3
import sys
import socket
ETH_P_ALL=3 # not defined in socket module, sadly...
s=socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.htons(ETH_P_ALL))
s.bind(("eth0", 0))

def parse_mac(b) :
    addr = ""
    for i in b:
        s = hex(i)[2:]
        if len(s) < 2:
            addr += "0"
        addr += s
        addr += ":"
    return addr[:-1]

while True :
    r=s.recv(2000)

    dst_addr = r[:6]
    src_addr = r[6:12]
    length = r[12:14]
    payload = r[14:]

    print("####################")
    print("Frame destination: ", parse_mac(dst_addr))
    print("Frame source:", parse_mac(src_addr))
    print(payload.decode())