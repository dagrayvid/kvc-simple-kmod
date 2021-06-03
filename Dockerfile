FROM quay.io/centos/centos:centos8.3.2011

RUN yum -y install git make

RUN yum -y install elfutils-libelf-devel kmod binutils kabi-dw kernel-abi-whitelists

RUN yum -y install kernel-core kernel-devel kernel-headers kernel-modules kernel-modules-extra 

WORKDIR /tmp

RUN git clone https://github.com/openshift-psap/kmods-via-containers.git

WORKDIR /tmp/kmods-via-containers

RUN make install DESTDIR=${MNT}/usr/local CONFDIR=${MNT}/etc/

RUN # Expecting kmod software version as an input to the build
ARG KMODVER=SRO

# Grab the software from upstream
RUN git clone https://github.com/openshift-psap/simple-kmod.git
WORKDIR simple-kmod

# Note, your host must have access to repos where kernel developement
# packages can be installed. If it doesn't the following steps will
# fail

# Prep and build the module
RUN yum install -y make sudo
RUN make buildprep KVER=$(uname -r) KMODVER=${KMODVER}
RUN make all       KVER=$(uname -r) KMODVER=${KMODVER}
RUN make install   KVER=$(uname -r) KMODVER=${KMODVER}

# Add the helper tools
WORKDIR /root/kvc-simple-kmod
ADD Makefile .
ADD simple-kmod-lib.sh .
ADD simple-kmod-wrapper.sh .
ADD simple-kmod.conf .
RUN mkdir -p /usr/lib/kvc/
RUN mkdir -p /etc/kvc/
RUN make install
