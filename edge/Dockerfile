FROM centos:7 as base_image
RUN yum update -y && \
    yum install -y which perl perl-Data-Dumper glibc.i686 libgcc.i686 libstdc++.i686 zlib.i686 libaio.i686 compat-libstdc++-33 libaio numactl-libs &&\
    yum install -y net-tools unzip bc java iproute &&\
    yum reinstall -y glibc-common &&\
    package-cleanup --dupes && package-cleanup --cleandupes &&\
    yum clean all && rm -rf /var/cache/yum

ENV ST_HOME=/root/Axway/SecureTransport

FROM base_image as install_image

WORKDIR /root/tmp
COPY build/axway_installer.properties .
COPY build/st_install.properties .

ENV ARCHIVE SecureTransport_5.5_Q4_2018_Install_linux-x86-64_BN620.zip
ENV REPOS=https://phx.delivery.axway.int/download_true_name.php?static=$ARCHIVE INSTALL_CRON=false

RUN curl -k $REPOS >${ARCHIVE} \
    && unzip ./$ARCHIVE \
    && rm ./$ARCHIVE \
    && ((tail -F /root/Axway/install.log &) \
    ; ./setup.sh -s $PWD/axway_installer.properties) \
    && rm -rf /root/tmp

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
