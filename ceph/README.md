# Ceph lab

## Part 1

1. Install ceph-ansible on the undercloud
```
yum install ceph-ansible
```

2. Put the following files in stack's home directory on your undercloud
   - [ceph.yaml](ceph.yaml)
   - [deploy-ceph.sh](deploy-ceph.sh)

3. Start the deplolyment
```
bash deploy-ceph.sh
```

## Part 2

1. Read [deploy-ceph.sh](deploy-ceph.sh)
   - How does it differ from the overcloud-deploy.sh created by quickstart?

2. Read [ceph.yaml](ceph.yaml)
   - Which directive writes configuratoin options directly to /etc/ceph.conf?
   - Which directive controls the memory and CPU allocated to each OSD container?
   - Which directive defines the disks which will host OSDs?
   - Which directive defines the OSD jounral disks?

## Part 3

Only do this if your deployment is finished.

1. Validate the overcloud as described in the last step of the oooq lab [../oooq/oooq-lab.txt](../oooq/oooq-lab.txt).

2. SSH into an overcloud controller and run the following as root to answer their respective questions
   - `docker ps | grep ceph` which containers are running?
   - `ceph -s`
	 - Are the monitors in quorum?
	 - What is the cluster health?
	 - How many OSDs are up?
   - `ceph df`
     - How much raw space does the cluster have?
	 - How many pools are there?

3. SSH into a ceph-storage node and run the following as root to answer their respective questions
	- `docker ps | grep ceph` which containers are running and how are they named? Do the names align with each OSDs disk?
	- `lsblk`
	  - How many partitions do /dev/vdb and /dev/vdc have and how big are they?
	  - How many partitions does /dev/vdd have and how big are they?
	  - Can you explain the difference?

4. SSH back into an overcloud controller after the validation and re-run `ceph df` to see if the number of objects in the pools have changed.
