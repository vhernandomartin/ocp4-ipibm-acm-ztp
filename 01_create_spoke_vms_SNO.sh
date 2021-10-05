#!/bin/bash
SPOKEVM=spoke1-master-0

qemu-img create -f qcow2 /var/lib/libvirt/images/${SPOKEVM}.qcow2 130G

virt-install --virt-type=kvm --name=${SPOKEVM} --ram 33792 --vcpus 8 --hvm --network network=lab-spoke,model=virtio,mac=aa:aa:aa:aa:de:01 --disk /var/lib/libvirt/images/${SPOKEVM}.qcow2,device=disk,bus=scsi,format=qcow2 --os-type Linux --os-variant rhel8.0 --graphics none --import --noautoconsole

virsh destroy ${SPOKEVM}
