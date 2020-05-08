# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Copyright (c) 2020 Axway Software SA and its affiliates. All rights reserved.
#
FROM registry.access.redhat.com/ubi8/ubi:8.0 as base_image

LABEL maintainer="Axway Software SA <https://support.axway.com>"
LABEL org.opencontainers.image.vendor="Axway"
LABEL org.opencontainers.image.documentation="https://docs.axway.com/category/mft"
LABEL org.opencontainers.image.title="SecureTransport Server"
LABEL org.opencontainers.image.description="SecureTransport Server Image"
LABEL org.opencontainers.image.url="https://git.ecd.axway.int/cloud/docker-st.git"
LABEL org.opencontainers.image.source="git@git.ecd.axway.int:cloud/docker-st.git"
LABEL org.opencontainers.image.documentation="https://docs.axway.com/category/mft"

# Update Base OS Packages and Install pre-requisites
RUN yum update -y && \
    yum install -y which procps glibc.i686 libgcc.i686 libstdc++.i686 zlib.i686 libaio.i686 libaio &&\
    yum clean all &&\
    rm -rf /var/cache/yum &&\
    find /usr/share/locale -mindepth 1 -maxdepth 1 ! -name 'en_US' ! -name 'locale.alias' | xargs -r rm -r

# Add User
RUN useradd -m -u 1001 -g 0 stuser && mkdir /home/stuser/tmp && chown stuser:0 /home/stuser/tmp

# Set Environment Variables
ENV ST_HOME=/home/stuser/Axway/SecureTransport LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8

#######
#
# Intermediate Image: Product Installation
#
######
FROM base_image as install_image

RUN yum install -y perl unzip

USER stuser

WORKDIR /home/stuser/tmp

ARG INSTALL_KIT

ADD --chown=stuser:0 $INSTALL_KIT installkit.zip

COPY --chown=stuser:0 build/ .
COPY --chown=stuser:0 build/scripts/entrypoint.sh $ST_HOME/docker/scripts/

# Do not install ST cron jobs
ENV INSTALL_CRON=false

# Perform silent installation
RUN chmod +x $ST_HOME/docker/scripts/*.sh &&\
    unzip installkit.zip &&\
    rm -f installkit.zip &&\
    ./setup.sh -s /home/stuser/tmp/axway_installer.properties

# Fix catalina logging
RUN scripts/logger-util.sh && \
    sed -i 's/\(>> "$CATALINA_BASE"\/logs\/catalina.out\)/#\1/' $ST_HOME/tomcat/bin/catalina.sh && \
    sed -i '/org.apache.catalina.startup.Bootstrap "$@" start \\/ s/\\/ \&/' $ST_HOME/tomcat/bin/catalina.sh && \
    sed -i '/com.tumbleweed.st.server.util.tomcat.As2ServerBootstrap "$@" start \\/ s/\\/ \&/' $ST_HOME/tomcat/bin/catalina.sh

######
#
# Final Image
#
#####
FROM base_image

COPY --chown=stuser:0 --from=install_image $ST_HOME $ST_HOME

USER stuser

WORKDIR $ST_HOME

ENTRYPOINT [ "/home/stuser/Axway/SecureTransport/docker/scripts/entrypoint.sh" ]
CMD ["all"]
