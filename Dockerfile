# https://hub.docker.com/_/centos/
FROM centos:7
LABEL maintainer="Chris Poppelaars"
ENV container docker
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8


RUN yum makecache fast; \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7; \
    yum install -y deltarpm; \
    yum check-update; \
    yum install -y sudo which python3-pip wget epel-release initscripts python3; \
    yum clean all

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

ENV PATH "$PATH:/root/.local/bin"

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install ansible

VOLUME [ "/sys/fs/cgroup" ]
CMD [ "/usr/sbin/init" ]
