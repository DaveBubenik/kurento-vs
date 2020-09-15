# our local base image
ARG UBUNTU_CODENAME="bionic"

FROM ubuntu:${UBUNTU_CODENAME}

ARG UBUNTU_CODENAME="bionic"
ARG KMS_VERSION="6.14.0"


LABEL description="Container for building/debugging Kurento in Visual Studio" 

# install build dependencies 
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Chicago
RUN apt-get update && apt-get install -y g++ rsync zip openssh-server make ninja-build gdb cmake nano
RUN apt-get update && apt-get install -y --no-install-recommends build-essential ca-certificates cmake git gnupg curl

#create user
RUN useradd -m -d /home/kurento -s /bin/bash -G sudo kurento
RUN echo "kurento:1234" | chpasswd

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5AFA7A83
# Add the repository to Apt
RUN echo "deb [arch=amd64] http://ubuntu.openvidu.io/${KMS_VERSION} ${UBUNTU_CODENAME} kms6" > "/etc/apt/sources.list.d/kurento.list"

# Install Kurento Media Server
RUN apt-get -q update && apt-get -q install --no-install-recommends --yes \
        kurento-media-server \
 && rm -rf /var/lib/apt/lists/*

# Install additional modules
# These might not be available, so allow errors
RUN apt-get -q update && apt-get -q install --no-install-recommends --yes \
        kms-chroma || true \
 && rm -rf /var/lib/apt/lists/*
RUN apt-get -q update && apt-get -q install --no-install-recommends --yes \
        kms-crowddetector || true \
 && rm -rf /var/lib/apt/lists/*
RUN apt-get -q update && apt-get -q install --no-install-recommends --yes \
        kms-platedetector || true \
 && rm -rf /var/lib/apt/lists/*
RUN apt-get -q update && apt-get -q install --no-install-recommends --yes \
        kms-pointerdetector || true \
 && rm -rf /var/lib/apt/lists/*

# Install debug symbols
RUN apt-key adv \
        --keyserver keyserver.ubuntu.com \
        --recv-keys F2EDC64DC5AEE1F6B9C621F0C8CAB6595FDFF622 \
 && echo "deb http://ddebs.ubuntu.com ${UBUNTU_CODENAME} main restricted universe multiverse" >/etc/apt/sources.list.d/ddebs.list \
 && echo "deb http://ddebs.ubuntu.com ${UBUNTU_CODENAME}-updates main restricted universe multiverse" >>/etc/apt/sources.list.d/ddebs.list \
 && apt-get -q update \
 && apt-get -q install --no-install-recommends --yes \
        kurento-dbg \
 && rm -rf /var/lib/apt/lists/*

#Install Dev
RUN apt-get update && apt-get install --no-install-recommends -y kurento-media-server-dev \
 && rm -rf /var/lib/apt/lists/*

# Update permissions on modules directory
RUN chmod -R 777 /usr/lib/x86_64-linux-gnu/gstreamer-1.5
RUN chmod -R 777 /usr/lib/x86_64-linux-gnu/kurento

# configure SSH for communication with Visual Studio 
RUN mkdir -p /var/run/sshd

RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \ 
   ssh-keygen -A 

# expose port 22 
EXPOSE 22
EXPOSE 8888

COPY ./entrypoint.sh /entrypoint.sh

CMD service ssh start && tail -f /dev/null