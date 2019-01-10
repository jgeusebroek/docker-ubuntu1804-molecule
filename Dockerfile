FROM ubuntu:bionic
LABEL maintainer="Jeroen Geusebroek"

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
       systemd \
       systemd-cron \
       python2.7 \
       ca-certificates \
       sudo \
    && ln -s /usr/bin/python2.7 /usr/bin/python \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean \
    # Disable agetty, fixes zombie agetty 100% cpu.
    # https://github.com/moby/moby/issues/4040
    && cp /bin/true /sbin/agetty

RUN apt-get update && apt-get install python-pip python-dev gcc libssl-dev libffi-dev -y \
    && pip install ansible molecule \
    && rm -Rf /var/lib/apt/lists/* \
    && apt-get clean

COPY files/initctl_faker .
RUN chmod +x initctl_faker && rm -fr /sbin/initctl && ln -s /initctl_faker /sbin/initctl

RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME [ "/sys/fs/cgroup" ]
CMD [ "/lib/systemd/systemd" ]