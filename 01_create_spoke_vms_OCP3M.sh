#!/bin/bash

NET_TYPE=ipv6 # Set this var accordingly -> ipv4/ipv6

SPOKEVMS=(spoke1-master-1 spoke1-master-2 spoke1-master-3)
NETWORK=lab-spoke
CLUSTER_NAME=mgmt-spoke1
DOMAIN=example.com
INSTALLER_VM=ipibm-installer
OCP_PARENT_DOMAIN=lab.example.com

SPOKE_CIDR_IPV4=192.168.120.1/24
SPOKE_IPV4_IPROUTE=192.168.120.1
SPOKE_IPV4_PREFIX=24
SPOKE_IPV4_INSTALLER_IP=192.168.120.100
SPOKE_IPV4_API_IP=192.168.120.10
SPOKE_IPV4_INGRESS_IP=192.168.120.11
IPV4_RANGE_START=192.168.120.2
IPV4_RANGE_END=192.168.120.254
MASTERS_IPV4=(192.168.120.20 192.168.120.21 192.168.120.22)
MASTERS_MAC_IPV4=(aa:aa:aa:aa:de:01 aa:aa:aa:aa:de:02 aa:aa:aa:aa:de:03)
INSTALLER_MAC_IPV4=aa:aa:aa:aa:de:00

SPOKE_CIDR_IPV6=2510:49:0:1101::1/64
SPOKE_IPV6_IPROUTE=2510:49:0:1101::1
SPOKE_IPV6_PREFIX=64
SPOKE_IPV6_INSTALLER_IP=2510:49:0:1101::100
SPOKE_IPV6_API_IP=2510:49:0:1101::10
SPOKE_IPV6_INGRESS_IP=2510:49:0:1101::11
IPV6_RANGE_START=2510:49:0:1101::2
IPV6_RANGE_END=2510:49:0:1101::ffff
MASTERS_IPV6=(2510:49:0:1101::20 2510:49:0:1101::21 2510:49:0:1101::22)
MASTERS_MAC_IPV6=(00:03:00:01:aa:aa:aa:aa:de:01 00:03:00:01:aa:aa:aa:aa:de:02 00:03:00:01:aa:aa:aa:aa:de:03)
INSTALLER_MAC_IPV6=00:03:00:01:aa:aa:aa:aa:de:00


function set_vars () {
  OCP_DOMAIN=${CLUSTER_NAME}.${DOMAIN}
  PWD=$(/usr/bin/pwd)
  IP_TYPE=$1
  if [ "${IP_TYPE}" = "ipv4" ]; then
    echo -e "+ Setting vars for a ipv4 cluster."
    echo -e "+ The network range configured is: ${SPOKE_CIDR_IPV4}"
    IPV="ip4"
    IPFAMILY="ipv4" #ok
    IPROUTE=${SPOKE_IPV4_IPROUTE} #ok
    IPPREFIX=${SPOKE_IPV4_PREFIX} #ok
    INSTALLER_IP=${SPOKE_IPV4_INSTALLER_IP}
    API_IP=${SPOKE_IPV4_API_IP} #ok
    INGRESS_IP=${SPOKE_IPV4_INGRESS_IP} #ok
    HOSTIDMAC="host mac" #ok
    IP_RANGE_START=${IPV4_RANGE_START} #ok
    IP_RANGE_END=${IPV4_RANGE_END} #ok
    MASTERS_IP=("${MASTERS_IPV4[@]}") #ok
    MASTERS_MAC=("${MASTERS_MAC_IPV4[@]}") #ok
    INSTALLER_MAC=${INSTALLER_MAC_IPV4}
  elif [ "${IP_TYPE}" = "ipv6" ]; then
    echo -e "+ Setting vars for a ipv6 cluster."
    echo -e "+ The network range configured is: ${SPOKE_CIDR_IPV6}"
    IPV="ip6"
    IPFAMILY="ipv6" #ok
    IPROUTE=${SPOKE_IPV6_IPROUTE} #ok
    IPPREFIX=${SPOKE_IPV6_PREFIX} #ok
    INSTALLER_IP=${SPOKE_IPV6_INSTALLER_IP}
    API_IP=${SPOKE_IPV6_API_IP} #ok
    INGRESS_IP=${SPOKE_IPV6_INGRESS_IP} #ok
    HOSTIDMAC="host id" #ok
    IP_RANGE_START=${IPV6_RANGE_START} #ok
    IP_RANGE_END=${IPV6_RANGE_END} #ok
    MASTERS_IP=("${MASTERS_IPV6[@]}") #ok
    MASTERS_MAC=("${MASTERS_MAC_IPV6[@]}") #ok
    INSTALLER_MAC=${INSTALLER_MAC_IPV6}
  else
    echo -e "+ A valid network type value should be provided: ipv4/ipv6."
  fi
}

function networks () {
echo -e "\n+ Defining virsh network and applying configuration..."
cat << EOF > ${NETWORK}-network.xml
<network>
  <name>${NETWORK}</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='${NETWORK}' stp='on' delay='0'/>
  <mac address='52:54:00:ec:9b:dd'/>
  <domain name='${NETWORK}'/>
  <dns>
    <host ip='${API_IP}'>
      <hostname>api</hostname>
      <hostname>api-int.${OCP_DOMAIN}</hostname>
      <hostname>api.${OCP_DOMAIN}</hostname>
    </host>
    <host ip='${INGRESS_IP}'>
      <hostname>apps</hostname>
      <hostname>console-openshift-console.apps.${OCP_DOMAIN}</hostname>
      <hostname>oauth-openshift.apps.${OCP_DOMAIN}</hostname>
      <hostname>prometheus-k8s-openshift-monitoring.apps.${OCP_DOMAIN}</hostname>
      <hostname>canary-openshift-ingress-canary.apps.${OCP_DOMAIN}</hostname>
      <hostname>assisted-service-open-cluster-management.apps.${OCP_DOMAIN}</hostname>
      <hostname>assisted-service-assisted-installer.apps.${OCP_DOMAIN}</hostname>
    </host>
  </dns>
  <ip family='${IPFAMILY}' address='${IPROUTE}' prefix='${IPPREFIX}'>
    <dhcp>
      <range start='${IP_RANGE_START}' end='${IP_RANGE_END}'/>
      <${HOSTIDMAC}='${MASTERS_MAC[0]}' name='${SPOKEVMS[0]}' ip='${MASTERS_IP[0]}'/>
      <${HOSTIDMAC}='${MASTERS_MAC[1]}' name='${SPOKEVMS[1]}' ip='${MASTERS_IP[1]}'/>
      <${HOSTIDMAC}='${MASTERS_MAC[2]}' name='${SPOKEVMS[2]}' ip='${MASTERS_IP[2]}'/>
      <${HOSTIDMAC}='${INSTALLER_MAC}' name='${INSTALLER_VM}' ip='${INSTALLER_IP}'/>
    </dhcp>
  </ip>
</network>
EOF

  virsh net-define ${NETWORK}-network.xml
  virsh net-autostart ${NETWORK}
  virsh net-start ${NETWORK}
}

function add_nic_installer_vm () {
  virsh attach-interface --domain ${INSTALLER_VM} --type network --source ${NETWORK} --mac ${INSTALLER_MAC_IPV4} --alias net2 --config
  virsh destroy ${INSTALLER_VM}
  virsh start ${INSTALLER_VM}
}

function create_vms () {
ID=1
for s in ${SPOKEVMS[@]}
do
  qemu-img create -f qcow2 /var/lib/libvirt/images/$s.qcow2 130G
  virt-install --virt-type=kvm --name=$s --ram 33792 --vcpus 8 --hvm --network network=${NETWORK},model=virtio,mac=aa:aa:aa:aa:de:0${ID} --disk /var/lib/libvirt/images/$s.qcow2,device=disk,bus=scsi,format=qcow2 --os-type Linux --os-variant rhel8.0 --graphics none --import --noautoconsole
  virsh destroy $s
  let ID++
done
}

function set_dns_hosts () {
  while [[ ${IP} = "" ]]
  do
    IP=$(virsh net-dhcp-leases ${NETWORK} |grep ${INSTALLER_MAC_IPV4}|tail -1|awk '{print $5}'|cut -d "/" -f 1)
    echo -e "+ Waiting to grab an IP from DHCP..."
    sleep 5
  done
  echo -e "+ IP already assigned: ${IP}"

  virsh net-update ${NETWORK} add dns-host "<host ip='${IP}'> <hostname>ipibm-installer</hostname> <hostname>ipibm-installer.lab-ipibm</hostname> <hostname>ipibm-installer.${OCP_DOMAIN}</hostname> </host>" --live --config
  virsh net-update ${NETWORK} add dns-host "<host ip='${INGRESS_IP}'> <hostname>assisted-service-open-cluster-management.apps.${OCP_PARENT_DOMAIN}</hostname> <hostname>assisted-service-assisted-installer.apps.${OCP_PARENT_DOMAIN}</hostname> </host>" --live --config
}

# MAIN
set_vars ${NET_TYPE}
networks
add_nic_installer_vm
create_vms
set_dns_hosts
