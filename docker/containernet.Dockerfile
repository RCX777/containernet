FROM ubuntu:24.04
LABEL maintainer="manuel@peuster.de"
ENV TZ=Europe/PARIS \
    DEBIAN_FRONTEND=noninteractive

# install required packages
RUN apt-get clean
RUN apt-get update -y && apt-get install -y \
    ca-certificates \
    git \
    net-tools \
    aptitude \
    build-essential \
    python3-setuptools \
    python3-dev \
    python3-pip \
    python3-venv \
    software-properties-common \
    ansible \
    curl \
    iptables \
    iputils-ping \
    sudo

RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
        https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt update -y && \
    apt install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin

COPY ./util/build-ovs-dpdk.sh /tmp/build-ovs-dpdk.sh
RUN chmod +x /tmp/build-ovs-dpdk.sh && \
    /tmp/build-ovs-dpdk.sh && \
    rm -rf /tmp/build-ovs-dpdk.sh

# install containernet
COPY . /containernet
WORKDIR /containernet
RUN PYTHON=python3 util/install.sh -fn

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN make install

# tell containernet that it runs in a container
ENV CONTAINERNET_NESTED=1

# Important: This entrypoint is required to start the OVS service
ENTRYPOINT ["util/docker/entrypoint.sh"]
CMD ["python3", "examples/containernet_example.py"]
