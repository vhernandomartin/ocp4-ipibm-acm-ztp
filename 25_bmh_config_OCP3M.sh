#!/bin/bash
SPOKEVMS=(spoke1-master-1 spoke1-master-2 spoke1-master-3)

IP=$(ip addr show eth2|grep inet|grep -v fe80|awk '{print $2}'|cut -d "/" -f 1)

if [ $(echo $IP|grep ":") ]; then 
  echo "IPV6 address" 
  NET_TYPE=ipv6
else 
  echo "IPV4 address" 
  NET_TYPE=ipv4
fi

ID=1
for s in ${SPOKEVMS[@]}
do
  cp 26_BareMetalHost-OCP3M_TEMPLATE.yaml 26_BareMetalHost-OCP3M_${NET_TYPE}_$s.yaml
  REDFISH_URL=$(/root/find_redfish_host.sh -n=${NET_TYPE} -s=$s)
  sed -i '/bmc:/!b;n;c\    address: '"${REDFISH_URL}"'' 26_BareMetalHost-OCP3M_${NET_TYPE}_$s.yaml
  sed -i 's/ID/'"$ID"'/' 26_BareMetalHost-OCP3M_${NET_TYPE}_$s.yaml
  sed -i 's/bmc-secret1/bmc-secret'"$ID"'/' 26_BareMetalHost-OCP3M_${NET_TYPE}_$s.yaml
  let ID++
done

