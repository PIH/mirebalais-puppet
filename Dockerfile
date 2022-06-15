FROM ubuntu:20.04

MAINTAINER Michael Seaton <mseaton@pih.org>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y git lsb-release wget software-properties-common ruby2.5-dev

ADD . /etc/puppet
RUN mv Gemfile2004-Docker Gemfile2004
WORKDIR /etc/puppet

RUN bash gem-update.sh

CMD /bin/bash