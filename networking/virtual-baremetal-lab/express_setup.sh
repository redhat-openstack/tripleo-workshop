#!/bin/bash

set -e

###############################################################################
echo "Generate ssh keys"
ssh-keygen


###############################################################################
echo "Install TripleO Repos"
{
yum -y install https://trunk.rdoproject.org/centos7/current/python2-tripleo-repos-0.0.1-0.20180418175107.ef4e12e.el7.centos.noarch.rpm
tripleo-repos -b queens current ceph
}  >> express.log

###############################################################################
echo "Install Virtualization Host + Virtual BMC, OpenvSwitch, git etc."
{
yum -y groupinstall 'Virtualization Host'
yum -y install git python2-setuptools python-virtualbmc openvswitch virt-install libguestfs-tools libguestfs-xfs
}  >> express.log


###############################################################################
echo "Enable nested virtualization."
{
cat << EOF > /etc/modprobe.d/kvm_intel.conf
options kvm-intel nested=1
options kvm-intel enable_shadow_vmcs=1
options kvm-intel enable_apicv=1
options kvm-intel ept=1
EOF

modprobe -r kvm_intel
modprobe kvm_intel
}  >> express.log

###############################################################################
echo "Compile and install dhcrelay from ics-dhcp."
{
yum -y install gcc make
useradd devuser
sudo -u devuser curl -o /home/devuser/dhcp-4-3-6-p1.tar.gz https://www.isc.org/downloads/file/dhcp-4-3-6-p1/
sudo -u devuser tar xvzf /home/devuser/dhcp-4-3-6-p1.tar.gz -C /home/devuser/
cd /home/devuser/dhcp-4.3.6-P1/
sudo -u devuser ./configure --prefix=/usr/local
sudo -u devuser make
make install
cd ~
}  >> express.log

###############################################################################
echo "Cloning lab from git repo"
{
git clone https://github.com/redhat-openstack/tripleo-workshop.git
}  >> express.log

###############################################################################
echo "Deploy the config files"
{
scp -r ./tripleo-workshop/networking/virtual-baremetal-lab/root/* /
chmod +x /usr/local/bin/generate_instackenv.py
}  >> express.log

###############################################################################
echo "Restart networking and Firewall"
{
systemctl restart network
systemctl restart firewalld
}  >> express.log

###############################################################################
echo "Enable IP Routing"
{
cat << EOF >  /etc/sysctl.d/90-ip-forwarding.conf
net.ipv4.ip_forward = 1
EOF

sysctl --system
}  >> express.log

###############################################################################
echo "Enable dhcp relay service on ctlplane networks."
{
systemctl daemon-reload
systemctl enable dhcrelay.service
systemctl start dhcrelay.service
systemctl status dhcrelay.service
}  >> express.log

###############################################################################
echo "Create libvirt networks."
{
# Make sure libvirt is running
systemctl status libvirtd.service || systemctl restart libvirtd.service
cd /root/tripleo-workshop/networking/virtual-baremetal-lab/libvirt/networks/
bash create_networks.sh
cd ~
}  >> express.log

###############################################################################
echo "Create disks for vms."
{
cd /var/lib/libvirt/images/
qemu-img create -f qcow2 -o preallocation=metadata overcloud-controller-0.qcow2 60G
qemu-img create -f qcow2 -o preallocation=metadata overcloud-controller-1.qcow2 60G
qemu-img create -f qcow2 -o preallocation=metadata overcloud-controller-2.qcow2 60G

qemu-img create -f qcow2 -o preallocation=metadata overcloud-compute1-0.qcow2 60G
qemu-img create -f qcow2 -o preallocation=metadata overcloud-compute2-0.qcow2 60G
qemu-img create -f qcow2 -o preallocation=metadata overcloud-compute3-0.qcow2 60G

qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph1-0-root.qcow2 60G
qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph1-0-osd0.qcow2 20G
qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph1-0-osd1.qcow2 20G
qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph1-0-osd2.qcow2 20G
qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph1-0-osd3.qcow2 20G

qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph2-0-root.qcow2 60G
qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph2-0-osd0.qcow2 20G
qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph2-0-osd1.qcow2 20G
qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph2-0-osd2.qcow2 20G
qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph2-0-osd3.qcow2 20G

qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph3-0-root.qcow2 60G
qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph3-0-osd0.qcow2 20G
qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph3-0-osd1.qcow2 20G
qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph3-0-osd2.qcow2 20G
qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph3-0-osd3.qcow2 20G

cd ~
}  >> express.log

###############################################################################
echo "Create overcloud vms."
}
cd /root/tripleo-workshop/networking/virtual-baremetal-lab/libvirt/vms
bash create_vms.sh

cd ~
}  >> express.log

###############################################################################
echo "Configure virtual BMC for overcloud nodes."
{
vbmc add --username admin --password password --port 6230 overcloud-controller-0
vbmc add --username admin --password password --port 6231 overcloud-controller-1
vbmc add --username admin --password password --port 6232 overcloud-controller-2
vbmc add --username admin --password password --port 6233 overcloud-compute1-0
vbmc add --username admin --password password --port 6234 overcloud-compute2-0
vbmc add --username admin --password password --port 6235 overcloud-compute3-0
vbmc add --username admin --password password --port 6236 overcloud-ceph1-0
vbmc add --username admin --password password --port 6237 overcloud-ceph2-0
vbmc add --username admin --password password --port 6238 overcloud-ceph3-0

vbmc start overcloud-controller-0
vbmc start overcloud-controller-1
vbmc start overcloud-controller-2
vbmc start overcloud-compute1-0
vbmc start overcloud-compute2-0
vbmc start overcloud-compute3-0
vbmc start overcloud-ceph1-0
vbmc start overcloud-ceph2-0
vbmc start overcloud-ceph3-0
}  >> express.log
vbmc list


###############################################################################
echo "Generate instack-env.json."
/usr/local/bin/generate_instackenv.py > /root/instackenv.json

###############################################################################
echo "Create undercloud vm."
{
cd /var/lib/libvirt/images/
# Download and decompress CentOS Cloud image
#curl -O https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2.xz
curl -O http://10.12.50.1/pub/tripleo-masterclass/CentOS-7-x86_64-GenericCloud.qcow2.xz
unxz CentOS-7-x86_64-GenericCloud.qcow2.xz

# Create a new image for undercloud
qemu-img create -f qcow2 undercloud.qcow2 40G

# Clone and resize the CentOS cloud image to our 40G undercloud image
virt-resize --expand /dev/sda1 CentOS-7-x86_64-GenericCloud.qcow2 undercloud.qcow2

# Set the root password
virt-customize -a undercloud.qcow2 --root-password password:Redhat01
}  >> express.log

# Create config drive

mkdir -p /tmp/cloud-init-data/
cat << EOF > /tmp/cloud-init-data/meta-data
instance-id: undercloud-instance-id
local-hostname: undercloud.example.com
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
EOF
cat << EOF > /tmp/cloud-init-data/user-data
#cloud-config
disable_root: false
ssh_authorized_keys:
  - $(cat ~/.ssh/id_rsa.pub)
EOF

{
genisoimage -o undercloud-config.iso -V cidata -r \
  -J /tmp/cloud-init-data/meta-data /tmp/cloud-init-data/user-data

# Launch the undercloud vm
virt-install --ram 16384 --vcpus 4 --os-variant centos7.0 \
--disk path=/var/lib/libvirt/images/undercloud.qcow2,device=disk,bus=virtio,format=qcow2 \
--disk path=/var/lib/libvirt/images/undercloud-config.iso,device=cdrom \
--import --noautoconsole --vnc \
--network network:default \
--network network:ctlplane,portgroup=ctlplane0 \
--name undercloud
}  >> express.log

# Get the IP address of the undercloud
undercloudip=$(virsh domifaddr undercloud | grep ipv4 | awk '{ print $4 }' | cut --fields=1 --delimiter='/')
echo "$undercloudip undercloud.example.com undercloud" >> /etc/hosts

echo "########################################################################"
echo "# DONE"
echo "#"
echo "# ssh root@undercloud.example.com  <-- To continue undercloud setup"
#ssh root@undercloud.example.com




