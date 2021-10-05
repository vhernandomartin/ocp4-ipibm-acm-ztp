#!/bin/bash

qemu-img create -f qcow2 -o preallocation=full /var/lib/libvirt/images/ipibm-worker-01_disk2.qcow2 30G 
qemu-img create -f qcow2 -o preallocation=full /var/lib/libvirt/images/ipibm-worker-01_disk3.qcow2 30G 
qemu-img create -f qcow2 -o preallocation=full /var/lib/libvirt/images/ipibm-worker-02_disk2.qcow2 30G 
qemu-img create -f qcow2 -o preallocation=full /var/lib/libvirt/images/ipibm-worker-02_disk3.qcow2 30G 
virsh attach-disk ipibm-worker-01 /var/lib/libvirt/images/ipibm-worker-01_disk2.qcow2 sdb --cache none
virsh attach-disk ipibm-worker-01 /var/lib/libvirt/images/ipibm-worker-01_disk3.qcow2 sdc --cache none
virsh attach-disk ipibm-worker-02 /var/lib/libvirt/images/ipibm-worker-02_disk2.qcow2 sdb --cache none
virsh attach-disk ipibm-worker-02 /var/lib/libvirt/images/ipibm-worker-02_disk3.qcow2 sdc --cache none
