FROM ubuntu:16.04
USER root

#apt installs
RUN apt-get update


RUN apt-get install openssh-server -y

RUN apt-get install curl wget -y

RUN apt-get install jq -y

RUN apt-get install nano -y

RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -
RUN apt-get install -y nodejs

#download and install stuff

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN mv kubectl /usr/local/bin
RUN chmod +x /usr/local/bin/kubectl

RUN apt-get install sudo

#install az cli
COPY ./Docker/installaz.sh ./installaz.sh
RUN chmod +x installaz.sh
RUN ./installaz.sh

 #customisations and things
RUN mkdir -p /var/run/sshd

#user mode stuff

RUN adduser --disabled-password --gecos "" acsuser && \
  echo "acsuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV HOME /home/acsuser

RUN npm install -g yo
RUN npm install -g generator-acsengine
RUN npm install -g kubecfg

COPY ./Docker/insight-yo.json /home/acsuser/.config/configstore/insight-yo.json

RUN chmod 777 -R /home/acsuser/.config

WORKDIR /home/acsuser

ARG ACSENGINE_VERSION=0.18.8

RUN wget -O acs-engine.tar.gz https://github.com/Azure/acs-engine/releases/download/v${ACSENGINE_VERSION}/acs-engine-v${ACSENGINE_VERSION}-linux-amd64.tar.gz 
RUN tar -xvf acs-engine.tar.gz
RUN mv acs-engine-v${ACSENGINE_VERSION}-linux-amd64/acs-engine /usr/local/bin
RUN chmod +x /usr/local/bin/acs-engine
RUN rm acs-engine.tar.gz
RUN rm -rf acs-engine-v${ACSENGINE_VERSION}-linux-amd64

COPY acsengine acsengine
COPY scripts ./scripts

RUN chmod +x scripts/*

RUN find /home/acsuser -type d -user root -exec chown -R acsuser: {} +

## If you want to be able to SSH in to this. 
#RUN echo "root:temppw" | chpasswd
#RUN echo "PermitRootLogin yes" > /etc/ssh/sshd_config
#EXPOSE 22
#CMD ["/usr/sbin/sshd", "-D"]

USER acsuser
RUN echo "alias k=\"kubectl\"" > ~/.bashrc
RUN echo "source <(kubectl completion bash)" >> ~/.bashrc
CMD ["/bin/bash"]