FROM rhel7:latest
MAINTAINER Balázs Miklós <mbalazs@ulx.hu>

ADD gitblit-service.sh /opt/
RUN yum --enablerepo=rhel-7-server-thirdparty-oracle-java-rpms -y install java-1.8.0-oracle tar \
  && yum clean all \
  && rm -rf /var/cache/yum \
  && curl -L -O http://dl.bintray.com/gitblit/releases/gitblit-1.7.1.tar.gz \
  && tar -zxvf gitblit-1.7.1.tar.gz -C /opt \
  && mv /opt/gitblit-1.7.1 /opt/gitblit \
  && mkdir -p /opt/gitblit-data \
  && chmod g+rwX /opt/gitblit-data \
  && chmod g+rwX /opt/gitblit \
  && chmod +x /opt/gitblit-service.sh

ENV GITBLIT_HOME /opt/gitblit
ENV GITBLIT_DATA /opt/gitblit-data

WORKDIR ${GITBLIT_HOME}
VOLUME ${GITBLIT_DATA}

ADD log4j.properties ${GITBLIT_HOME}/
ADD openshift.groovy ${GITBLIT_HOME}/groovy/

EXPOSE 8080
EXPOSE 8443
EXPOSE 9418
EXPOSE 29418

cmd ["/opt/gitblit-service.sh"]
