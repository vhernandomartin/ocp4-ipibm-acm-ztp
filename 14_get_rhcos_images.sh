#!/bin/bash

RHCOS_RELEASE=$(openshift-baremetal-install coreos print-stream-json | jq -r '.architectures.x86_64.artifacts.metal.release')
RHCOS_ISO=$(openshift-baremetal-install coreos print-stream-json | jq -r '.architectures.x86_64.artifacts.metal.formats.iso.disk.location')
RHCOS_PXE_ROOTFS=$(openshift-baremetal-install coreos print-stream-json | jq -r '.architectures.x86_64.artifacts.metal.formats.pxe.rootfs.location')
IP=$(ip addr show eth2|grep inet|grep -v fe80|awk '{print $2}'|cut -d "/" -f 1)

if [ $(echo $IP|grep ":") ]; then 
  echo "IPV6 address" 
  IP=[$IP]
  echo $IP
else 
  echo "IPV4 address" 
  echo $IP
fi

yum install -y wget
wget -P /var/www/html ${RHCOS_ISO}
wget -P /var/www/html  ${RHCOS_PXE_ROOTFS}

cp 15_agent-service-config_TEMPLATE.yaml 15_agent-service-config.yaml

sed -i 's/RHCOS_RELEASE/'"${RHCOS_RELEASE}"'/' 15_agent-service-config.yaml
sed -i 's/RHCOS_ISO/'"$(basename $RHCOS_ISO)"'/' 15_agent-service-config.yaml
sed -i 's/RHCOS_PXE_ROOTFS/'"$(basename $RHCOS_PXE_ROOTFS)"'/' 15_agent-service-config.yaml
sed -i 's/INSTALLER_IP/'"${IP}"'/' 15_agent-service-config.yaml
