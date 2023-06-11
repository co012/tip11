#!/bin/python3
import sys
import socket


from scapy.all import (
    sniff
)


def handle_pkt(pkt):
    pkt.show()
    sys.stdout.flush()


def main():
    while True:

        sniff(iface = "eth0",
            prn = lambda x: handle_pkt(x))

if __name__ == '__main__':
    main()