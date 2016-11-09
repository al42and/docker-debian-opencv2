# Dockerfile to build environment with python2 and opencv2

FROM resin/rpi-raspbian:latest
MAINTAINER Andrey Alekseenko <al42and@gmail.com>

# apt-get first
RUN apt-get update && apt-get install -qy \
	cmake \
	git \
	libopencv-dev \
	python-dev \
	python-opencv \
	python-numpy \
	python-scipy \
	python-matplotlib \
	python-pandas \
	python-pip \
	python-setuptools \
	wget \
	x11vnc \
	xvfb \
	xauth \
	openssh-server

# Install dev packages for building sklearn
RUN apt-get install -qy build-essential

# python libraries
RUN pip install -U \
	scikit-learn

# Remove temporary packages
RUN apt-get purge -qy \
	build-essential && apt-get autoremove -qy

# Clean-up
RUN rm -rf /var/lib/apt/lists/*
# RUN apt-get clean # Not necessary, Debian does that for you
RUN rm -rf '/root/.cache/pip/'

RUN mkdir /app

# X11VNC configuration
RUN mkdir -p /root/.vnc && x11vnc -storepasswd 1234 /root/.vnc/passwd
COPY run_vnc /bin/run_vnc
RUN chmod +x /bin/run_vnc
EXPOSE 5900

# ssh configuration
RUN echo 'root:1234' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd
COPY run_ssh /bin/run_ssh
RUN chmod +x /bin/run_ssh
EXPOSE 22
