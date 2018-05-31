FROM 192.168.24.1:8787/tripleoqueens/centos-binary-swift-proxy-server:current-tripleo-rdo
USER root
CMD patch /usr/lib/python2.7/site-packages/swift/common/utils.py swift.patch
USER swift
