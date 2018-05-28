#!/usr/bin/python

import json
import libvirt
from xml.dom import minidom

NODE_PREFIX = 'overcloud'
VBMC_HOST = '192.168.122.1'
VBMC_USER = 'admin'
VBMC_PASSWORD = 'password'

VBMC_PORT_MAP = {'overcloud-controller-0': 6230,
                 'overcloud-controller-1': 6231,
                 'overcloud-controller-2': 6232,
                 'overcloud-compute1-0': 6233,
                 'overcloud-compute2-0': 6234,
                 'overcloud-compute3-0': 6235,
                 'overcloud-ceph1-0': 6236,
                 'overcloud-ceph2-0': 6237,
                 'overcloud-ceph3-0': 6238}

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