#!/usr/bin/python

import json
import libvirt
from xml.dom import minidom

NODE_PREFIX = 'overcloud'
VBMC_HOST = '192.168.122.1'
VBMC_USER = 'admin'
VBMC_PASSWORD = 'password'

VBMC_PORT_MAP = {'overcloud-controller-0': 6240,
                 'overcloud-controller-1': 6241,
                 'overcloud-controller-2': 6242,
                 'overcloud-compute1-0': 6243,
                 'overcloud-compute2-0': 6244,
                 'overcloud-compute3-0': 6245,
                 'overcloud-ceph1-0': 6246,
                 'overcloud-ceph2-0': 6247,
                 'overcloud-ceph3-0': 6248}

instackenv = {'nodes': []}
nodes = instackenv['nodes']
data_format = '"pm_type": "pxe_ipmitool", ' \
              '"mac": ["{mac}"], ' \
              '"pm_user": "' + VBMC_USER + '", ' \
              '"pm_password": "' + VBMC_PASSWORD + '", ' \
              '"pm_addr": "' + VBMC_HOST + '", ' \
              '"pm_port": "{vbmc_port}", ' \
              '"name": "{domain_name}"'


conn = libvirt.openReadOnly(None)
domains = conn.listAllDomains(0)
for domain in domains:
    if domain.name().startswith(NODE_PREFIX):
        raw_xml = domain.XMLDesc()
        xml = minidom.parseString(raw_xml)
        mac = xml.getElementsByTagName('interface')[0].getElementsByTagName('mac')[0].attributes['address'].value
        data = data_format.format(mac=mac,
                                  vbmc_port=VBMC_PORT_MAP[domain.name()],
                                  domain_name=domain.name())
        nodes.append(json.loads('{' + data + '}'))

print json.dumps(instackenv, indent=4,  sort_keys=True)