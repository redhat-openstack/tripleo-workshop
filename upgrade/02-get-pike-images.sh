#!/bin/bash

set -euxo pipefail
cd $HOME

RELEASE=pike
THT="$HOME/tht-${RELEASE}"

IMAGE_LOCATION="http://10.12.50.1/pub/tripleo-masterclass/pike-tripleo/overcloud-full.tar"
# IMAGE_LOCATION="https://images.rdoproject.org/pike/delorean/current-tripleo/overcloud-full.tar"

mkdir overcloud-full-pike
pushd overcloud-full-pike
curl -O "$IMAGE_LOCATION"
tar -xvf overcloud-full.tar
mv overcloud-full{,-pike}.qcow2
mv overcloud-full{,-pike}.initrd
mv overcloud-full{,-pike}.vmlinuz
ln -s ../ironic-python-agent.initramfs
ln -s ../ironic-python-agent.kernel
openstack overcloud image upload --os-image-name overcloud-full-pike.qcow2 --image-path $HOME/overcloud-full-pike
popd

curl -o ${RELEASE}-container-images-template.yaml.j2 https://raw.githubusercontent.com/openstack/tripleo-common/stable/${RELEASE}/container-images/overcloud_containers.yaml.j2

openstack overcloud container image prepare \
  --template-file ${RELEASE}-container-images-template.yaml.j2 \
  --namespace tripleo${RELEASE} \
  --tag current-tripleo \
  --push-destination 192.168.24.1:8787/tripleo${RELEASE} \
  --output-images-file ~/${RELEASE}-container-images.yaml \
  -e $THT/environments/docker.yaml \
  -e $THT/environments/docker-ha.yaml \
  -e basic-deployment.yaml \

openstack overcloud container image upload \
  --debug \
  --config-file ~/${RELEASE}-container-images.yaml \

openstack overcloud container image prepare \
  --namespace 192.168.24.1:8787/tripleo${RELEASE} \
  --tag current-tripleo \
  --output-env-file ~/${RELEASE}-container-params.yaml \
  -e $THT/environments/docker.yaml \
  -e $THT/environments/docker-ha.yaml \
  -e basic-deployment.yaml \
