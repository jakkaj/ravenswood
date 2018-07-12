FROM ubuntu:16.04 

RUN apt-get update

RUN apt-get install curl wget -y && \
    apt-get install iputils-ping -y && \
    apt-get install nano -y && \    
    apt-get install openjdk-8-jre-headless wget netcat-openbsd -y && \
    apt-get install tar -y

RUN apt-get install python-minimal -y

# RUN apt-get install software-properties-common python-software-properties debconf-utils -y

# RUN echo "oracle-java10-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections

# RUN add-apt-repository -y ppa:linuxuprising/java
# RUN apt-get update
# RUN apt-get install oracle-java10-installer -y

RUN curl -s http://archive.apache.org/dist/storm/apache-storm-1.2.2/apache-storm-1.2.2.tar.gz | \
      tar zxf - -C /opt && \
      mv /opt/apache-storm-1.2.2 /opt/apache-storm

ADD configure.sh /