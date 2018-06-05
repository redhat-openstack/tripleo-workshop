source /home/stack/stackrc
cd /home/stack


openstack overcloud deploy \
  --templates \
  --ntp-server clock.redhat.com \
  -n /home/stack/templates/network_data.yaml \
  -r /home/stack/templates/roles_data.yaml \
  -e /home/stack/environments/nodes_data.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/ceph-ansible/ceph-ansible.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/low-memory-usage.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/network-environment.yaml \
  -e /home/stack/environments/network-environment-overrides.yaml \
  -e /home/stack/environments/service_net_map_overrides.yaml \
  -e /home/stack/environments/scheduler_hints_env.yaml \
  -e /home/stack/environments/custom_hostnames.yaml \
  -e /home/stack/environments/predictable_ips.yaml \
  -e /home/stack/templates/ceph/ceph.yaml \
  -e /home/stack/environments/docker_registry.yaml
