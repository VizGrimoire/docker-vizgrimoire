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
        npm nodejs-legacy \
        ruby \
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

# VizGrimoireJS-lib: install, including testing support
RUN sudo npm install -g jshint uglifyjs
RUN git clone https://github.com/VizGrimoire/VizGrimoireJS-lib.git
RUN cd VizGrimoireJS-lib && make

# Time to install jasmine-headless-webkit
RUN sudo apt-get update && \
    sudo apt-get -y install --no-install-recommends \
    libqt4-dev qt4-qmake libqtwebkit-dev g++ \
    xvfb
RUN sudo gem install jasmine-headless-webkit
# We need to fix two issues
ADD specrunner.cpp ${SCRIPTS_DIR}/specrunner.cpp
ADD command_line.rb ${SCRIPTS_DIR}/command_line.rb
RUN sudo cp ${SCRIPTS_DIR}/specrunner.cpp /var/lib/gems/1.9.1/gems/jasmine-headless-webkit-0.8.4/ext/jasmine-webkit-specrunner/specrunner.cpp
RUN sudo cp ${SCRIPTS_DIR}/command_line.rb /var/lib/gems/1.9.1/gems/jasmine-headless-webkit-0.8.4/lib/jasmine/headless/command_line.rb
ADD jasmine-empty.yml ${SCRIPTS_DIR}/jasmine-empty.yml
RUN xvfb-run sudo jasmine-headless-webkit -j ${SCRIPTS_DIR}/jasmine-empty.yml

# VizGrimoireJS: install, create HTML and use the JSON from GrimoireLib
RUN git clone https://github.com/VizGrimoire/VizGrimoireJS.git
RUN ln -s ${JSON_DIR} VizGrimoireJS/browser/data/json && \
    cd VizGrimoireJS && make

# Hack to change organizations to companies for VizJS
ADD orgs2companies.sh ${SCRIPTS_DIR}/orgs2companies.sh
RUN JSON_DIR=${JSON_DIR} ${SCRIPTS_DIR}/orgs2companies.sh

USER root
RUN mv /var/www/html /var/www/html.orig && \
    ln -s ${DEPLOY_USER_DIR}/VizGrimoireJS/browser /var/www/html