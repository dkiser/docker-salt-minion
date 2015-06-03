# CentOS 7 Docker image for Salt Minion

FROM centos:centos7

MAINTAINER Domingo Kiser domingo.kiser@gmail.com

RUN echo "create salt user and directories" \
    && groupadd -r salt \
    && useradd  -r -g salt salt \
    && mkdir -p \
      /etc/salt \
      /var/log/salt \
      /var/cache/salt \
      /var/run/salt \
    && chown -R salt:salt \
      /etc/salt \
      /var/cache/salt \
      /var/log/salt \
      /var/run/salt

ENV SALT_VERSION 2015.5.1
ENV LOG_LEVEL error

# Yum updates and installs
RUN yum install -y epel-release
RUN yum update -y && yum install -y \
  python \
  python-devel \
  python-pip \
  gcc \
  swig \
  gcc \
  openssl-devel \
  zeromq3-devel \
  supervisor \
  openssh-clients \
  git

# Install everything salt needs via PIP
ENV SWIG_FEATURES "-cpperraswarn -includeall -I/usr/include/openssl"
RUN pip install \
  M2Crypto \
  pyzmq \
  PyYAML \
  pycrypto \
  msgpack-python \
  jinja2 \
  psutil \
  requests \
  GitPython \
  croniter \
  supervisor-stdout \
  salt==$SALT_VERSION

# Volumes
VOLUME ["/etc/salt"]

# Run as non privileged user
USER salt

# Launch supervisor (lets us run syndic in future if we need to expand)
CMD /usr/bin/salt-minion --log-level="$LOG_LEVEL"
