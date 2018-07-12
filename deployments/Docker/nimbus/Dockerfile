FROM jakkaj/stormbase
#based on FROM mattf/storm-base
MAINTAINER Jordan Knight <jorkni@microsoft.com> by Matthew Farrellee <matt@cs.wisc.edu>

ADD start.sh /

EXPOSE 3772 6627

WORKDIR /opt/apache-storm

COPY cluster.xml ./log4j2

ENTRYPOINT ["/start.sh"]
#CMD bash -C 'bash'