# Base Image
FROM ubuntu:22.04

# Metadata
LABEL base_image="biocontainers:latest" \
      version="3"   \
      software="CPC2" \
      software.version="v1.0.1" \
      about.summary="an open source tandem mass spectrometry sequence database search tool" \
      about.home="http://comet-ms.sourceforge.net/" \
      about.documentation="http://comet-ms.sourceforge.net/parameters/parameters_2016010/" \
      about.license="SPDX:Apache-2.0" \
      about.license_file="/usr/share/common-licenses/Apache-2.0" \
      about.tags="Prediction" \
      extra.identifiers.biotools=cpc2

# Maintainer
LABEL maintainer="Nils Hoffmann <n.hoffmann@fz-juelich.de>"
USER root

RUN mkdir /data /config

# Add user biodocker with password biodocker
RUN groupadd fuse && \
    useradd --create-home --shell /bin/bash --user-group --uid 1000 --groups sudo,fuse biodocker && \
    echo `echo "biodocker\nbiodocker\n" | passwd biodocker` && \
    chown biodocker:biodocker /data && \
    chown biodocker:biodocker /config

ENV PATH=$PATH:/opt/conda/bin
ENV PATH=$PATH:/home/biodocker/bin
ENV HOME=/home/biodocker
ENV DEBIAN_FRONTEND noninteractive

RUN mkdir /home/biodocker/bin

RUN apt update && apt install --no-install-recommends -y curl python3 pip build-essential libsvm-dev libsvm-tools &&   \
    apt clean && \
    apt purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY requirements.txt /tmp/
COPY ./bin /home/biodocker/bin/
COPY ./data /home/biodocker/data/
# we need to change ownership to allow execution of the scripts in the bin folder as the workdir
RUN chmod -R 755 /home/biodocker/bin/* && chown -R biodocker:biodocker /home/biodocker/*
ENV PATH /home/biodocker/bin/:$PATH

RUN pip3 install --no-cache-dir -r /tmp/requirements.txt && rm /tmp/requirements.txt

VOLUME ["/data", "/config"]

USER biodocker
#CMD ["/bin/CPC2.py"]
WORKDIR /data