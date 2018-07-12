FROM jakkaj/stormbase
#based on FROM mattf/storm-base
MAINTAINER Jordan Knight <jorkni@microsoft.com> by Matthew Farrellee <matt@cs.wisc.edu>

ADD start.sh /

EXPOSE 6700 6701 6702 6703

WORKDIR /opt/apache-storm

ENTRYPOINT ["/start.sh"]
#CMD ["sh", "-c", "tail -f /dev/null"]