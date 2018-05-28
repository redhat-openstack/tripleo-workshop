virsh net-define ovs-ctlplane.xml
virsh net-autostart ctlplane
virsh net-start ctlplane

virsh net-define ovs-trunk.xml
virsh net-autostart trunk
virsh net-start trunk


