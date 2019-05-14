# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Copyright (c) 2019 Axway Software SA and its affiliates. All rights reserved.
#
FROM centos:7 as base_image
RUN yum update -y && \
    yum install -y which perl perl-Data-Dumper glibc.i686 libgcc.i686 libstdc++.i686 zlib.i686 libaio.i686 compat-libstdc++-33 libaio numactl-libs &&\
    yum install -y net-tools unzip bc iproute wget &&\
    yum reinstall -y glibc-common &&\
    package-cleanup --dupes && package-cleanup --cleandupes &&\
    yum clean all && rm -rf /var/cache/yum

ENV ST_HOME=/root/Axway/SecureTransport

FROM base_image as install_image

WORKDIR /root/tmp
COPY build/axway_installer.properties .
COPY build/st_install.properties .

ARG VERSION_BASE="5.5_Q1_2019"
ARG RELEASE_BASE="BN833"
ARG STATIC_BASE="SecureTransport_${VERSION_BASE}_Install_linux-x86-64_${RELEASE_BASE}.zip"

ARG URL_BASE="https://axway.bintray.com/delivery/"

RUN curl -kL $URL_BASE$STATIC_BASE -o st-distrib.zip && \
    unzip st-distrib.zip && \
    rm st-distrib.zip && \
    ((tail -F /root/Axway/install.log &) ; \
    ./setup.sh -s $PWD/axway_installer.properties) && \
    rm -rf /root/tmp

WORKDIR $ST_HOME
COPY build/scripts $ST_HOME/docker_scripts/

# Enable Service Logging to Console
RUN chmod +x $ST_HOME/docker_scripts/*.sh && \
    $ST_HOME/docker_scripts/logger-util.sh && \
    sed -i 's/\(>> "$CATALINA_BASE"\/logs\/catalina.out\)/#\1/' /root/Axway/SecureTransport/tomcat/bin/catalina.sh && \
    sed -i '/org.apache.catalina.startup.Bootstrap "$@" start \\/ s/\\/ \&/' /root/Axway/SecureTransport/tomcat/bin/catalina.sh && \
    sed -i '/com.tumbleweed.st.server.util.tomcat.As2ServerBootstrap "$@" start \\/ s/\\/ \&/' /root/Axway/SecureTransport/tomcat/bin/catalina.sh

FROM base_image

COPY --from=install_image /root/Axway/ /root/Axway/

WORKDIR $ST_HOME

ENTRYPOINT [ "/root/Axway/SecureTransport/docker_scripts/entrypoint.sh" ]
CMD [ "all" ]
