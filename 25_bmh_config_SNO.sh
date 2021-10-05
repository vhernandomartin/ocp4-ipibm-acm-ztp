#!/bin/bash
SPOKEVM=spoke1-master-0

IP=$(ip addr show eth2|grep inet|grep -v fe80|awk '{print $2}'|cut -d "/" -f 1)

if [ $(echo $IP|grep ":") ]; then 
  echo "IPV6 address" 
  NET_TYPE=ipv6
else 
  echo "IPV4 address" 
  NET_TYPE=ipv4
fi

REDFISH_URL=$(/root/find_redfish_host.sh -n=${NET_TYPE} -s=${SPOKEVM})

cp 26_BareMetalHost-SNO_TEMPLATE.yaml 26_BareMetalHost-SNO_${NET_TYPE}.yaml
sed -i '/bmc:/!b;n;c\    address: '"${REDFISH_URL}"'' 26_BareMetalHost-SNO_${NET_TYPE}.yaml 

