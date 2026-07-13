#!/bin/bash

ON_SITE_DNS="nameserver 10.255.255.254\nsearch ad.glpoly.net covestro.net bmsnrwmes.cnb glpoly.net ant.glpoly.net localdomain"
REMOTE_DNS="nameserver 9.9.9.9"

if /mnt/c/Windows/System32/ipconfig.exe /all | grep -i "DNS Servers" | grep -q "9.9.9.9"; then
    CONTENT="$REMOTE_DNS"
    echo "Zscaler found, using remote DNS"
else
    CONTENT="$ON_SITE_DNS"
    echo "No Zscaler found, using on-site DNS"
fi

sudo chattr -i /etc/resolv.conf
printf "$CONTENT\n" | sudo tee /etc/resolv.conf >/dev/null
sudo chattr +i /etc/resolv.conf

echo "Done. Current resolv.conf:"
cat /etc/resolv.conf
