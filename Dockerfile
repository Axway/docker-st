FROM centos:7 as base_image
#RUN yum install -y unzip bind-utils cronie perl perl-Data-Dumper libaio glibc.i686 zlib.i686 net-tools which 
RUN yum update -y && \
    yum install -y which perl perl-Data-Dumper glibc.i686 libgcc.i686 libstdc++.i686 zlib.i686 libaio.i686 compat-libstdc++-33 libaio numactl-libs &&\
    yum install -y net-tools unzip bc java iproute &&\
    yum reinstall -y glibc-common &&\
    package-cleanup --dupes && package-cleanup --cleandupes &&\
    yum clean all && rm -rf /var/cache/yum

FROM base_image as install_image

WORKDIR /root/tmp
COPY ./resources/axway_installer.properties .
COPY ./resources/st_install.properties .

ENV ARCHIVE SecureTransport_5.4.0_Install_linux-x86-64_BN1125.zip 
ENV REPOS=https://ptx.delivery.axway.int/download_true_name.php?static=$ARCHIVE INSTALL_CRON=false

RUN curl -k $REPOS >${ARCHIVE} \
    && unzip ./$ARCHIVE \
    && rm ./$ARCHIVE \
    && ((tail -F /root/Axway/install.log &) \
    ; ./setup.sh -s $PWD/axway_installer.properties) \
    && rm -rf /root/tmp
#COPY ./${ARCHIVE} .
#RUN unzip ./$ARCHIVE && rm ./$ARCHIVE

FROM base_image

COPY --from=install_image /root/Axway/SecureTransport/ /root/Axway/SecureTransport/

WORKDIR /root/Axway/SecureTransport

EXPOSE 444 443 80 22 17617 17627 19617 19627 

#EXPOSE 444  # Admin UI
#EXPOSE 8005  #Tomcat shutdown port
COPY resources/start.sh .
CMD [ "./start.sh" ]
