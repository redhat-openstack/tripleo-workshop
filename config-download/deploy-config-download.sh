#!/usr/bin/env bash

HEAT=1
DOWN=0
CONF=0

source ~/stackrc

if [[ $HEAT -eq 1 ]]; then
    QUEENS=1
    ROCKY=0
    # 12 minutes to deploy baremetal and generate config data
    if [[ $QUEENS -eq 1 ]]; then
	# Assuming 'quickstart.sh --release queens' and borrowing line 34 of overcloud-deploy.sh
	time openstack overcloud deploy \
	--templates /usr/share/openstack-tripleo-heat-templates/ \
	--libvirt-type qemu --compute-flavor oooq_compute --ceph-storage-flavor oooq_ceph --block-storage-flavor oooq_blockstorage --swift-storage-flavor oooq_objectstorage --timeout 90  -e /home/stack/cloud-names.yaml      -e /usr/share/openstack-tripleo-heat-templates/environments/docker.yaml   -e /usr/share/openstack-tripleo-heat-templates/environments/docker-ha.yaml  -e /home/stack/containers-default-parameters.yaml  -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml -e /usr/share/openstack-tripleo-heat-templates/environments/net-single-nic-with-vlans.yaml -e /home/stack/network-environment.yaml  -e /usr/share/openstack-tripleo-heat-templates/environments/low-memory-usage.yaml    -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml  --validation-warnings-fatal   --compute-scale 1 --control-scale 1 --ceph-storage-scale 0  --ntp-server clock.redhat.com \
	-e /usr/share/openstack-tripleo-heat-templates/environments/config-download-environment.yaml
	#--config-download
	# add --config-download to make DOWN and CONF unnecessary
    fi
    if [[ $ROCKY -eq 1 ]]; then
	# Works for 'quickstart.sh --release master-tripleo-ci'
	time openstack overcloud deploy \
	--templates /usr/share/openstack-tripleo-heat-templates/ \
	--libvirt-type qemu --compute-flavor oooq_compute --ceph-storage-flavor oooq_ceph --block-storage-flavor oooq_blockstorage --swift-storage-flavor oooq_objectstorage --timeout 90  -e /home/stack/cloud-names.yaml      -e /usr/share/openstack-tripleo-heat-templates/environments/docker.yaml   -e /usr/share/openstack-tripleo-heat-templates/environments/docker-ha.yaml  -e /home/stack/containers-default-parameters.yaml  -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml -e /usr/share/openstack-tripleo-heat-templates/environments/net-single-nic-with-vlans.yaml -e /home/stack/network-environment.yaml  -e /usr/share/openstack-tripleo-heat-templates/environments/low-memory-usage.yaml    -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml  --validation-warnings-fatal   --compute-scale 1 --control-scale 1 --ceph-storage-scale 0  --ntp-server clock.redhat.com \
	--no-config-download
        # remove --no-config-download to make DOWN and CONF unnecessary
    fi
fi
# -------------------------------------------------------
if [[ $DOWN -eq 1 ]]; then
    # 1 minute to download config data and make inventory
    if [[ $(openstack stack list | grep overcloud | wc -l) -eq 0 ]]; then
	echo "No overcloud heat stack. Exiting"
	exit 1
    fi
    tripleo-config-download
    if [[ ! -d tripleo-config-download ]]; then
	echo "tripleo-config-download cmd didn't create tripleo-config-download dir"
    else
	pushd tripleo-config-download
	tripleo-ansible-inventory --static-yaml-inventory inventory.yaml
	ansible --ssh-extra-args "-o StrictHostKeyChecking=no" -i inventory.yaml all -m ping
	popd
	echo "pushd tripleo-config-download"
	echo 'ansible -i inventory.yaml all -m shell -b -a "hostname"'
    fi
fi
# -------------------------------------------------------
if [[ $CONF -eq 1 ]]; then
    # 25 minutes to configure _minimal_ overcloud
    if [[ ! -e tripleo-config-download/deploy_steps_playbook.yaml ]]; then
	# Rocky (master) and Queens differ on if this is necessary
	MOST_RECENT_DIR=$(ls -trF tripleo-config-download | grep / | tail -1)
    fi
    time ansible-playbook \
	 -v \
	 --ssh-extra-args "-o StrictHostKeyChecking=no" --timeout 240 \
	 --become \
	 -i tripleo-config-download/inventory.yaml \
	 tripleo-config-download/$MOST_RECENT_DIR/deploy_steps_playbook.yaml
fi
