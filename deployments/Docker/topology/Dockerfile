FROM jakkaj/stormbase
#based on FROM mattf/storm-base
MAINTAINER Jordan Knight <jorkni@microsoft.com> by Matthew Farrellee <matt@cs.wisc.edu>

ADD start.sh /

WORKDIR /opt/apache-storm
COPY built/* ./
ENTRYPOINT ["/start.sh"]
#CMD ["sh", "-c", "tail -f /dev/null"]
