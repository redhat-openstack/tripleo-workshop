openstack overcloud container image prepare \
  --namespace docker-registry.engineering.redhat.com/rhosp13 \
  --tag-from-label {version}-{release} \
  --prefix openstack \
  --set ceph_namespace=registry.access.redhat.com/rhceph \
  --set ceph_image=rhceph-3-rhel7 \
  --set ceph_tag=latest \
  --push-destination 172.20.0.1:8787 \
  --output-images-file /home/stack/templates/container_images.yaml \
  --output-env-file /home/stack/templates/docker-images.yaml
