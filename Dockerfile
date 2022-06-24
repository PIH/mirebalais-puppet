FROM ubuntu:20.04

MAINTAINER Michael Seaton <mseaton@pih.org>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y git lsb-release wget software-properties-common

ADD . /etc/puppet
ADD Gemfile2004-Docker /etc/puppet/Gemfile2004
WORKDIR /etc/puppet

RUN bash gem-update.sh

CMD /bin/bash