# Copyright (C) 2015 Bitergia
# GPLv3 License

FROM bitergia/ubuntu-trusty:latest
MAINTAINER Alvaro del Castillo <acs@bitergia.com>

ENV DEBIAN_FRONTEND noninteractive
ENV DEPLOY_USER bitergia
ENV DEPLOY_USER_DIR /home/${DEPLOY_USER}
ENV SCRIPTS_DIR ${DEPLOY_USER_DIR}/scripts

# Helper scripts
RUN mkdir ${DEPLOY_USER_DIR}/scripts

# install dependencies
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        bash \
        git git-core \
        tree ccze \
        psmisc \
        python \
        apache2 \
        python-mysqldb\
        make \
        python-dateutil python-rpy2 \
        python-scipy python-sqlalchemy python-jsonpickle \
        p7zip \
        && \
    apt-get clean && \
    find /var/lib/apt/lists -type f -delete

# MySQL install and config and db creation
ADD configure-mysql.sh ${SCRIPTS_DIR}/configure-mysql.sh
# preseed debconf to set the mysql root password
RUN ${SCRIPTS_DIR}/configure-mysql.sh
RUN apt-get update && apt-get install -qy mysql-server

USER ${DEPLOY_USER}
WORKDIR ${DEPLOY_USER_DIR}

# JSON data metrics shared between VizGrimoireJS and GrimoireLib
ENV JSON_DIR ${DEPLOY_USER_DIR}/json
RUN mkdir -p ${JSON_DIR}

# GrimoireLib: install, execute with test dbs and generate JSON data
RUN git clone https://github.com/VizGrimoire/GrimoireLib.git
RUN sudo service mysql start && \
    cd GrimoireLib/testing && ./recreate-test-dbs.sh && \
    cd ../vizGrimoireJS && \
    ln -s ../vizgrimoire . && ln -s ../grimoirelib_alch . && \
    ./report_tool.py -c ../testing/automator.conf -o ${JSON_DIR}

# VizGrimoireJS: install, create HTML and use the JSON from GrimoireLib
RUN git clone https://github.com/VizGrimoire/VizGrimoireJS.git
RUN ln -s ${JSON_DIR} VizGrimoireJS/browser/data/json && \
    cd VizGrimoireJS && make

USER root
RUN mv /var/www/html /var/www/html.orig && \
    ln -s ${DEPLOY_USER_DIR}/VizGrimoireJS/browser /var/www/html