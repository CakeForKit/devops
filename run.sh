#!/bin/bash

# -i - входной интерфейс
# dport - порт назначения
# DNAT - изменяет адрес и порт назначения
sudo iptables -t nat -A PREROUTING -i ens33 -p tcp --dport 2222 -j DNAT --to-destination 192.168.75.2:22
sudo iptables -t nat -A POSTROUTING -d 192.168.75.2 -p tcp --dport 22 -j MASQUERADE

sudo iptables -A FORWARD -i ens33 -o ens37 -p tcp --dport 22 -j ACCEPT
sudo iptables -A FORWARD -i ens37 -o ens33 -p tcp --sport 22 -j ACCEPT

sudo netfilter-persistent save